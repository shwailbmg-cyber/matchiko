#!/usr/bin/env python3
"""Lints the lines a branch ADDS compared with the base branch.

Only new lines are checked, so old code never blocks a job; the rule is
"no new violations". Rules (docs/FACTORY.md § Gate):

  design    D1 raw colour outside lib/core/theme      D2 non-directional layout (breaks Arabic)
            D3 user-facing text not from l10n
  security  S1 print/debugPrint in app code           S2 cleartext http:// URL
            S3 secret-looking string                  S4 TLS / backup / cleartext switches
  database  Q1 applied migration edited or deleted    Q2 security definer without search_path = ''
            Q3 new table without RLS                  Q4 new function not revoked from public/anon
            Q5 migration without a database test

An added line may carry `// factory-lint: ignore <RULE> <reason>`; reviewers
check that the reason is real.

Usage: diff_lint.py <commit>   the commit where the branch left the base
                               (git merge-base); exit 1 when a rule fails
"""
from __future__ import annotations

import re
import subprocess
import sys

IGNORE = re.compile(r"factory-lint:\s*ignore\s+([A-Z]\d)")
RAW_COLOR = re.compile(r"\bColor\(0x[0-9A-Fa-f]{6,8}\)|Color\.fromARGB\(|Color\.fromRGBO\(")
NON_DIRECTIONAL = [
    re.compile(r"\bEdgeInsets\.only\([^)]*\b(left|right)\s*:"),
    re.compile(r"\bAlignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)\b"),
    re.compile(r"\bTextAlign\.(left|right)\b"),
    re.compile(r"\bPositioned\([^)]*\b(left|right)\s*:"),
    re.compile(r"\bBorderRadius\.only\([^)]*\b(topLeft|topRight|bottomLeft|bottomRight)\s*:"),
]
FROM_LTRB = re.compile(r"\bEdgeInsets\.fromLTRB\(\s*([\d.]+)\s*,\s*[\d.]+\s*,\s*([\d.]+)\s*,")
# Text('…') / Text("…") with at least three letters in a row and no interpolation-only content.
HARD_TEXT = re.compile(r"""\b(?:Text|Tooltip|SnackBar)\(\s*(?:const\s+)?(?:Text\(\s*)?(['"])((?:(?!\1).)*)\1""")
PRINT = re.compile(r"(?<![\w.])(print|debugPrint)\(")
CLEARTEXT = re.compile(r"""['"]http://(?!localhost|127\.0\.0\.1|10\.0\.2\.2)""")
SECRETS = [
    re.compile(r"sbp_[A-Za-z0-9]{20,}"),
    re.compile(r"sb_secret_[A-Za-z0-9_-]{10,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"eyJhbGciOi[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\."),
    re.compile(r"\bsk_live_[A-Za-z0-9]{10,}"),
]
SWITCHES = re.compile(
    r"badCertificateCallback|allowBackup\s*=\s*\"true\"|usesCleartextTraffic\s*=\s*\"true\""
)


def is_app_dart(path: str) -> bool:
    return (
        path.startswith("app/lib/")
        and path.endswith(".dart")
        and not path.endswith((".g.dart", ".freezed.dart"))
        and "/l10n/gen/" not in path
    )


def lint_line(path: str, line: str) -> list[tuple[str, str]]:
    """(rule, message) for one added line."""
    found: list[tuple[str, str]] = []
    stripped = line.strip()
    if is_app_dart(path) and not stripped.startswith("//"):
        if "/core/theme/" not in path and RAW_COLOR.search(line):
            found.append(("D1", "raw colour; use a token from MkColors"))
        if any(r.search(line) for r in NON_DIRECTIONAL):
            found.append(("D2", "not directional; use EdgeInsetsDirectional / AlignmentDirectional / TextAlign.start|end / PositionedDirectional"))
        m = FROM_LTRB.search(line)
        if m and float(m.group(1)) != float(m.group(2)):
            found.append(("D2", "fromLTRB with different left and right; use EdgeInsetsDirectional.fromSTEB"))
        for m in HARD_TEXT.finditer(line):
            text = re.sub(r"\$\{[^}]*\}|\$\w+", "", m.group(2))
            if re.search(r"[A-Za-z؀-ۿ]{3,}", text):
                found.append(("D3", "user-facing text must come from app_en/fr/ar.arb (AppLocalizations)"))
                break
        if PRINT.search(line):
            found.append(("S1", "print/debugPrint in app code (may leak personal data)"))
        if CLEARTEXT.search(line):
            found.append(("S2", "cleartext http:// URL"))
    if path.startswith("app/") and "service_role" in line:
        found.append(("S3", "service_role must never appear in the app"))
    if not path.startswith("factory/") and any(r.search(line) for r in SECRETS):
        found.append(("S3", "looks like a secret; secrets live in Supabase/GitHub secrets only"))
    if path.startswith("app/") and SWITCHES.search(line):
        found.append(("S4", "weakens TLS, backup or cleartext protection"))
    ignored = set(IGNORE.findall(line))
    return [(rule, msg) for rule, msg in found if rule not in ignored]


FUNC = re.compile(r"create\s+(or\s+replace\s+)?function\s+(public\.\w+)\s*\(", re.I)
TABLE = re.compile(r"create\s+table\s+(?:if\s+not\s+exists\s+)?(public\.\w+)", re.I)


def lint_migration(path: str, sql: str) -> list[tuple[str, str]]:
    """Rules for a migration file added by the branch (whole file)."""
    found = []
    flat = re.sub(r"--[^\n]*", "", sql)
    for m in FUNC.finditer(flat):
        name = m.group(2)
        header = flat[m.start(): flat.find("$$", m.start()) if "$$" in flat[m.start():] else len(flat)]
        if re.search(r"security\s+definer", header, re.I) and not re.search(
            r"set\s+search_path\s*=\s*''", header, re.I
        ):
            found.append(("Q2", f"{name}: security definer without set search_path = ''"))
        if not m.group(1):  # brand-new function: must be revoked from the default grants
            short = name.split(".")[1]
            if not re.search(rf"revoke\b[^;]*\b{re.escape(short)}\s*\([^;]*from\b[^;]*\b(public|anon)\b", flat, re.I | re.S):
                found.append(("Q4", f"{name}: new function is not revoked from public/anon"))
    for m in TABLE.finditer(flat):
        if not re.search(rf"alter\s+table\s+{re.escape(m.group(1))}\s+enable\s+row\s+level\s+security", flat, re.I):
            found.append(("Q3", f"{m.group(1)}: new table without 'enable row level security'"))
    return found


def git(*args: str) -> str:
    return subprocess.run(["git", *args], capture_output=True, text=True, check=True).stdout


def added_lines(base: str) -> list[tuple[str, int, str]]:
    out, path, n = [], "", 0
    for line in git("diff", "-U0", "--no-color", base, "HEAD").splitlines():
        if line.startswith("+++ "):
            path = line[6:] if line.startswith("+++ b/") else ""
        elif line.startswith("@@"):
            m = re.search(r"\+(\d+)", line)
            n = int(m.group(1)) if m else 0
        elif line.startswith("+") and not line.startswith("+++"):
            out.append((path, n, line[1:]))
            n += 1
    return out


def main(base: str) -> int:
    problems: list[str] = []
    for path, n, line in added_lines(base):
        for rule, msg in lint_line(path, line):
            problems.append(f"{path}:{n}: {rule} {msg}")
    status = [l.split("\t") for l in git("diff", "--name-status", base, "HEAD").splitlines() if l]
    new_migrations = []
    for parts in status:
        code, path = parts[0], parts[-1]
        if "supabase/migrations/" in "".join(parts[1:]):
            if code.startswith("A"):
                new_migrations.append(path)
            else:
                problems.append(f"{path}: Q1 an applied migration was changed ({code}); add a new migration instead")
    for path in new_migrations:
        for rule, msg in lint_migration(path, open(path).read()):
            problems.append(f"{path}: {rule} {msg}")
    if new_migrations and not any("supabase/tests/database/" in p[-1] for p in status):
        problems.append("supabase/migrations: Q5 a migration was added without adding or changing a test in supabase/tests/database/")
    for p in problems:
        print(p)
    print(f"diff lint: {len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
