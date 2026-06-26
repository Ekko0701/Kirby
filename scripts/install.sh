#!/usr/bin/env bash
# Kirby를 빌드해 /Applications에 설치(갱신)하고 실행한다.
# 사용법: ./scripts/install.sh
set -euo pipefail

cd "$(dirname "$0")/.."

echo "▶︎ Tuist 프로젝트 생성…"
tuist generate --no-open

echo "▶︎ 빌드(Debug)…"
xcodebuild -workspace Kirby.xcworkspace -scheme Kirby \
  -configuration Debug -destination 'platform=macOS,arch=arm64' build \
  -quiet

APP=$(/usr/bin/find ~/Library/Developer/Xcode/DerivedData -name 'Kirby.app' \
  -path '*Build/Products/Debug*' 2>/dev/null | head -1)
if [ -z "$APP" ]; then echo "✖ 빌드 산출물을 찾지 못했습니다."; exit 1; fi

echo "▶︎ /Applications/Kirby.app 갱신…"
/usr/bin/osascript -e 'quit app "Kirby"' 2>/dev/null || true
/usr/bin/ditto "$APP" /Applications/Kirby.app

echo "▶︎ 실행…"
open /Applications/Kirby.app
echo "✓ 완료 — Launchpad/Spotlight에서도 'Kirby'로 실행할 수 있습니다."
