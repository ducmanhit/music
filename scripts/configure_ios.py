#!/usr/bin/env python3
import argparse
import plistlib
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--bundle-id', default='com.ducmanhit.offlinemusic')
parser.add_argument('--display-name', default='Offline Music')
args = parser.parse_args()

root = Path(__file__).resolve().parents[1]
info_path = root / 'ios' / 'Runner' / 'Info.plist'
project_path = root / 'ios' / 'Runner.xcodeproj' / 'project.pbxproj'

if not info_path.exists() or not project_path.exists():
    raise SystemExit('Chưa có thư mục ios. Hãy chạy flutter create --platforms=ios . trước.')

with info_path.open('rb') as handle:
    info = plistlib.load(handle)

info['CFBundleDisplayName'] = args.display_name
info['UIBackgroundModes'] = sorted(set(info.get('UIBackgroundModes', []) + ['audio']))
info['UIFileSharingEnabled'] = True
info['LSSupportsOpeningDocumentsInPlace'] = True
info['UISupportsDocumentBrowser'] = False
info['NSLocalNetworkUsageDescription'] = (
    'Offline Music cần truy cập mạng nội bộ để nhận file nhạc từ máy tính qua Wi-Fi.'
)

with info_path.open('wb') as handle:
    plistlib.dump(info, handle, sort_keys=False)

project = project_path.read_text(encoding='utf-8')

def replace_bundle(match: re.Match[str]) -> str:
    old_value = match.group(1).strip().strip('"')
    suffix = '.RunnerTests' if 'RunnerTests' in old_value else ''
    return f'PRODUCT_BUNDLE_IDENTIFIER = {args.bundle_id}{suffix};'

project = re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);', replace_bundle, project)
project = re.sub(r'IPHONEOS_DEPLOYMENT_TARGET = [^;]+;', 'IPHONEOS_DEPLOYMENT_TARGET = 13.0;', project)
project_path.write_text(project, encoding='utf-8')
print(f'Configured iOS bundle id: {args.bundle_id}')
