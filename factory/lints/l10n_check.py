#!/usr/bin/env python3
"""Every user-facing string exists in English, French and Arabic.

Checks app/lib/l10n/app_{en,fr,ar}.arb: same keys, no empty value, same
{placeholders} in every language. Exit 1 on any difference.
"""
import json
import re
import sys
from pathlib import Path

L10N = Path(__file__).resolve().parents[2] / "app/lib/l10n"
PLACEHOLDER = re.compile(r"\{(\w+)\}")


def problems(files: dict[str, dict]) -> list[str]:
    out = []
    en = {k: v for k, v in files["en"].items() if not k.startswith("@")}
    for lang in ("fr", "ar"):
        other = {k: v for k, v in files[lang].items() if not k.startswith("@")}
        for key in sorted(set(en) - set(other)):
            out.append(f"app_{lang}.arb: missing key '{key}'")
        for key in sorted(set(other) - set(en)):
            out.append(f"app_{lang}.arb: extra key '{key}' (not in app_en.arb)")
        for key in sorted(set(en) & set(other)):
            if not str(other[key]).strip():
                out.append(f"app_{lang}.arb: '{key}' is empty")
            if set(PLACEHOLDER.findall(str(en[key]))) != set(PLACEHOLDER.findall(str(other[key]))):
                out.append(f"app_{lang}.arb: '{key}' placeholders differ from English")
    for key, value in en.items():
        if not str(value).strip():
            out.append(f"app_en.arb: '{key}' is empty")
    return out


if __name__ == "__main__":
    found = problems({l: json.loads((L10N / f"app_{l}.arb").read_text()) for l in ("en", "fr", "ar")})
    for p in found:
        print(p)
    print(f"l10n check: {len(found)} problem(s)")
    sys.exit(1 if found else 0)
