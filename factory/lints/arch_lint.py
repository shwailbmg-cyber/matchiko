#!/usr/bin/env python3
"""Architecture rules for the Flutter app, checked on the whole of app/lib.

The rules are written for people in .claude/skills/matchiko-architecture.
This script is the part a machine can check:

  A1  domain/ is pure Dart: no Flutter, no packages that do input/output,
      no import from data/ or presentation/
  A2  presentation/ and widgets never import a data/ folder or a backend
      package: they go through a repository interface from domain/
  A3  data/ never imports presentation/ or the widget libraries
  A4  core/ and shared/ never import a feature (core/router is the one
      place that knows every screen); core/ never imports shared/data
  A5  a feature never imports another feature
  A6  a file is at most FILE_MAX lines, tests included
  A7  a function or method is at most FUNC_MAX lines (BUILD_MAX for a
      widget's build method)

Code written before these rules is listed in arch_baseline.json with the
size it had. A listed file or function may shrink but never grow; anything
not listed must respect the limits. `--write-baseline` rewrites the list
(owner only: factory/lints is a protected path for factory jobs).

Function lengths are measured on formatted code (`dart format` is part of
the gate): a declaration starts on a line at member indentation and runs to
the next declaration. Generated files are skipped.

Usage: arch_lint.py [--write-baseline] [--all]
       --all prints the baseline's known violations too (the cleanup list)
"""
import json
import posixpath
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASELINE = Path(__file__).resolve().parent / "arch_baseline.json"
PACKAGE = "matchiko"

FILE_MAX = 400
FUNC_MAX = 60
BUILD_MAX = 80

GENERATED = (".g.dart", ".freezed.dart", ".mocks.dart")
IMPORT = re.compile(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""")
CONTAINER = re.compile(
    r"^(?:abstract |sealed |final |base |interface |mixin )*"
    r"(?:class|mixin|extension type|extension|enum)\b\s*(\w+)?"
)
NAME = re.compile(r"([A-Za-z_]\w*(?:\.\w+)?)\s*(?:<[^()]*>)?\s*\(")
GETTER = re.compile(r"\bget\s+(\w+)")
ASSIGN = re.compile(r"(?<![=!<>])=(?![=>])")

# Packages that read or write the outside world. Only data/ may use them.
IO_PACKAGES = {
    "supabase_flutter", "supabase", "postgrest", "gotrue", "realtime_client",
    "storage_client", "functions_client", "dio", "http",
    "shared_preferences", "flutter_secure_storage", "sqflite", "hive", "drift",
    "firebase_core", "firebase_messaging", "google_sign_in",
}
UI_PACKAGES = {"go_router", "flutter_riverpod", "riverpod"}
PURE_PACKAGES = {"freezed_annotation", "json_annotation", "meta", "collection"}
WIDGET_LIBS = {"material.dart", "widgets.dart", "cupertino.dart", "rendering.dart"}


def layer_of(rel: str) -> tuple[str, str]:
    """('feature:<name>'|'core'|'shared'|'root', 'domain'|'data'|'presentation'|...)."""
    parts = rel.split("/")
    if parts[0] == "features" and len(parts) >= 3:
        return f"feature:{parts[1]}", parts[2] if len(parts) > 3 else ""
    if parts[0] in ("core", "shared"):
        return parts[0], parts[1] if len(parts) > 2 else ""
    return "root", ""


def import_problems(rel: str, uris: list[str]) -> list[tuple[str, str, str]]:
    """[(rule, key detail, message)] for one file's imports."""
    area, layer = layer_of(rel)
    out = []

    def bad(rule: str, uri: str, why: str):
        out.append((rule, uri, why))

    for uri in uris:
        pkg, inner, t_area, t_layer = None, None, None, None
        if not uri.startswith(("dart:", "package:")):  # a relative import
            folder = rel.rsplit("/", 1)[0] if "/" in rel else ""
            uri = f"package:{PACKAGE}/" + posixpath.normpath(posixpath.join(folder, uri))
        if uri.startswith("package:"):
            pkg, _, inner = uri[len("package:"):].partition("/")
            if pkg == PACKAGE:
                t_area, t_layer = layer_of(inner)
        own = pkg == PACKAGE

        if layer == "domain":
            if uri.startswith("dart:"):
                if uri in ("dart:ui", "dart:io", "dart:html"):
                    bad("A1", uri, "domain is pure Dart")
            elif own:
                if t_layer != "domain" and not (t_area == "core" and t_layer == ""):
                    bad("A1", uri, "domain may only import other domain files")
            elif pkg is not None and pkg not in PURE_PACKAGES:
                bad("A1", uri, "domain is pure Dart: no Flutter, no I/O package")

        if layer in ("presentation", "widgets"):
            if own and t_layer == "data":
                bad("A2", uri, "screens go through a repository interface, not data/")
            elif pkg in IO_PACKAGES:
                bad("A2", uri, "backend packages belong in data/")

        if layer == "data":
            if own and t_layer in ("presentation", "widgets"):
                bad("A3", uri, "data never imports the UI")
            elif pkg == "flutter" and inner in WIDGET_LIBS:
                bad("A3", uri, "data never imports the widget libraries")
            elif pkg in UI_PACKAGES - {"flutter_riverpod", "riverpod"}:
                bad("A3", uri, "data never navigates")

        if area in ("core", "shared") and own and t_area.startswith("feature:"):
            if not (area == "core" and layer == "router"):
                bad("A4", uri, f"{area}/ never imports a feature")
        if area == "core" and own and t_area == "shared" and t_layer == "data":
            bad("A4", uri, "core/ never imports shared/data")

        if area.startswith("feature:") and own and t_area.startswith("feature:") and t_area != area:
            bad("A5", uri, "a feature never imports another feature; move it to shared/")
    return out


def declarations(lines: list[str]) -> list[tuple[str, int, int]]:
    """[(name, first line number, length)] of functions and methods."""
    out = []
    container, name, start, last, head = None, None, None, None, ""

    def close():
        nonlocal name, start, last, head
        if start is not None and name:
            out.append((f"{container}.{name}" if container else name, start + 1, last - start + 1))
        name, start, last, head = None, None, None, ""

    for i, raw in enumerate(lines):
        line = raw.rstrip("\n")
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip(" "))
        text = line.strip()
        member = 2 if container else 0
        if indent == 0:
            if text.startswith("}") and container:
                close()
                container = None
                continue
            found = CONTAINER.match(text)
            if found:
                close()
                container = found.group(1) or "extension"
                continue
        if indent > member:
            if start is not None:
                last = i
            continue
        if indent < member:
            continue
        if text[0] in ")]}":  # the end of the current declaration's signature or body
            if start is not None:
                last = i
                if not name:
                    name = function_name(head + " " + text)
            continue
        close()
        if text.startswith(("//", "@", "import ", "export ", "part ", "library ")):
            continue
        start, last, head = i, i, text
        name = function_name(text)
    close()
    return out


def function_name(head: str) -> str | None:
    """The function's name, or None when the declaration is a field."""
    paren = head.find("(")
    getter = GETTER.search(head)
    if getter and (paren == -1 or getter.start() < paren):
        return getter.group(1)
    if paren == -1:
        return None
    assign = ASSIGN.search(head)
    if assign and assign.start() < paren:
        return None
    found = NAME.search(head)
    return found.group(1) if found else None


def scan(root: Path = ROOT) -> dict[str, tuple[int, str]]:
    """{key: (measured value, message)} for every violation in the app."""
    found = {}
    lib, test = root / "app/lib", root / "app/test"
    for base in (lib, test):
        for path in sorted(base.rglob("*.dart")):
            rel = path.relative_to(base).as_posix()
            if path.name.endswith(GENERATED) or rel.startswith("l10n/gen/"):
                continue
            shown = path.relative_to(root).as_posix()
            lines = path.read_text(encoding="utf-8").splitlines()
            if len(lines) > FILE_MAX:
                found[f"A6 {shown}"] = (len(lines), f"{len(lines)} lines, the limit is {FILE_MAX}")
            if base is test:
                continue
            uris = [m.group(1) for m in map(IMPORT.match, lines) if m]
            for rule, uri, why in import_problems(rel, uris):
                found[f"{rule} {shown} -> {uri}"] = (1, why)
            for name, at, length in declarations(lines):
                cap = BUILD_MAX if name.endswith(".build") or name == "build" else FUNC_MAX
                if length > cap:
                    found[f"A7 {shown}::{name}"] = (length, f"line {at}: {length} lines, the limit is {cap}")
    return found


def main(argv: list[str]) -> int:
    found = scan()
    if "--write-baseline" in argv:
        BASELINE.write_text(json.dumps({k: v[0] for k, v in sorted(found.items())}, indent=1) + "\n")
        print(f"arch lint: baseline written, {len(found)} known violation(s)")
        return 0
    known = json.loads(BASELINE.read_text()) if BASELINE.exists() else {}
    new = {k: v for k, v in found.items() if k not in known or v[0] > known[k]}
    for key, (value, why) in sorted(new.items()):
        grew = f" (it was {known[key]} when the rule was added: it may shrink, not grow)" if key in known else ""
        print(f"{key}: {why}{grew}")
    if "--all" in argv:
        for key, (value, why) in sorted(found.items()):
            if key not in new:
                print(f"known  {key}: {why}")
    print(f"arch lint: {len(new)} problem(s), {len(found) - len(new)} known from before the rules")
    return 1 if new else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
