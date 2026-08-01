#!/usr/bin/env python3
"""Fast repository checks that run before Flutter analysis.

The Dart analyzer and widget tests remain authoritative. This script catches
missing local imports, forbidden visual effects, merge markers and exact
adjacent duplicate lines before the macOS build starts.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
errors: list[str] = []

forbidden = {
    "LinearGradient(": "gradient is not allowed in the Studio Flat design",
    "RadialGradient(": "gradient is not allowed in the Studio Flat design",
    "SweepGradient(": "gradient is not allowed in the Studio Flat design",
    "BoxShadow(": "drop shadows are not allowed in the flat design",
    "BackdropFilter(": "glass blur is not allowed in the Studio Flat design",
    "<<<<<<<": "unresolved merge marker",
    "=======": "unresolved merge marker",
    ">>>>>>>": "unresolved merge marker",
}
local_import_re = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)

for path in sorted(LIB.rglob("*.dart")):
    text = path.read_text(encoding="utf-8")
    for needle, reason in forbidden.items():
        if needle in text:
            errors.append(f"{path.relative_to(ROOT)}: {reason}: {needle}")

    previous_nonblank: tuple[str, int] | None = None
    for line_number, line in enumerate(text.splitlines(), start=1):
        stripped = line.strip()
        if not stripped:
            continue
        is_named_arg = re.match(r'^[A-Za-z_]\w*\s*:', stripped) is not None
        if previous_nonblank and is_named_arg and stripped == previous_nonblank[0]:
            errors.append(
                f"{path.relative_to(ROOT)}:{line_number}: exact adjacent duplicate line `{stripped}`"
            )
        previous_nonblank = (stripped, line_number)

    for imported in local_import_re.findall(text):
        if imported.startswith("package:") or imported.startswith("dart:"):
            continue
        target = (path.parent / imported).resolve()
        if not target.exists():
            errors.append(f"{path.relative_to(ROOT)}: missing local import {imported}")

required = [
    ROOT / "pubspec.yaml",
    ROOT / "lib/main.dart",
    ROOT / "lib/services/app_preferences.dart",
    ROOT / "lib/utils/app_theme.dart",
    ROOT / ".github/workflows/build-ipa.yml",
]
for path in required:
    if not path.exists():
        errors.append(f"missing required file: {path.relative_to(ROOT)}")

pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
name_match = re.search(r"(?m)^name:\s*([a-z0-9_]+)\s*$", pubspec)
version_match = re.search(
    r"(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$",
    pubspec,
)
if not name_match or name_match.group(1) != "offline_music":
    errors.append("pubspec.yaml: package name must be offline_music")
if not version_match:
    errors.append("pubspec.yaml: missing valid Flutter version (major.minor.patch+build)")
else:
    major, minor, patch, build = map(int, version_match.groups())
    if major < 13 or build < 1:
        errors.append(
            f"pubspec.yaml: unexpected version {major}.{minor}.{patch}+{build}"
        )

workflow = (ROOT / ".github/workflows/build-ipa.yml").read_text(encoding="utf-8")
for command in (
    "flutter analyze",
    "flutter test",
    "flutter build ios --release --no-codesign",
    "actions/upload-artifact@v4",
):
    if command not in workflow:
        errors.append(f"workflow missing required step: {command}")

if errors:
    print("Static verification failed:\n")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print(f"Static verification passed for {len(list(LIB.rglob('*.dart')))} Dart files.")
