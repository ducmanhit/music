#!/usr/bin/env python3
"""Fast repository checks before Flutter analysis and widget tests."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
errors: list[str] = []

forbidden = {
    "LinearGradient(": "gradient is not allowed in V15",
    "RadialGradient(": "gradient is not allowed in V15",
    "SweepGradient(": "gradient is not allowed in V15",
    "BackdropFilter(": "glass blur is not allowed in V15",
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

    for imported in local_import_re.findall(text):
        if imported.startswith("package:") or imported.startswith("dart:"):
            continue
        target = (path.parent / imported).resolve()
        if not target.exists():
            errors.append(f"{path.relative_to(ROOT)}: missing local import {imported}")

required = [
    ROOT / "pubspec.yaml",
    ROOT / "lib/main.dart",
    ROOT / "lib/screens/search_screen.dart",
    ROOT / "lib/screens/now_playing_screen.dart",
    ROOT / "lib/widgets/app_modal.dart",
    ROOT / "lib/widgets/mini_player.dart",
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
    errors.append("pubspec.yaml: missing valid version major.minor.patch+build")
else:
    major, minor, patch, build = map(int, version_match.groups())
    if major < 15 or build < 1:
        errors.append(f"pubspec.yaml: unexpected version {major}.{minor}.{patch}+{build}")

main_source = (ROOT / "lib/main.dart").read_text(encoding="utf-8")
for label in ("Trang chủ", "Tìm kiếm", "Thư viện", "Cài đặt"):
    if label not in main_source:
        errors.append(f"main.dart: missing bottom-navigation label {label}")

now_playing = (ROOT / "lib/screens/now_playing_screen.dart").read_text(encoding="utf-8")
if "LayoutBuilder(" not in now_playing:
    errors.append("now_playing_screen.dart: LayoutBuilder is required")

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
