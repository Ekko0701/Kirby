#!/usr/bin/env bash
# Kirby 릴리스 파이프라인: 빌드 → Developer ID 서명 → 공증 → staple → zip
#   → GitHub Release 업로드 → Homebrew tap(cask) 생성/갱신.
#
# 사전 준비(최초 1회, docs/09-homebrew-distribution.md 참고):
#   1) Apple Developer Program 가입 + Xcode에 계정 로그인
#   2) "Developer ID Application" 인증서 생성
#   3) 공증 자격증명 저장:
#        xcrun notarytool store-credentials KirbyNotary \
#          --apple-id <you@email> --team-id <TEAMID> --password <app-specific-password>
#   4) 환경변수 설정:
#        export KIRBY_SIGN_ID="Developer ID Application: Your Name (TEAMID)"
#        export KIRBY_NOTARY_PROFILE="KirbyNotary"
#
# 사용법:  ./scripts/release.sh [version]   (기본 0.1.0)
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-0.1.0}"
REPO="Ekko0701/Kirby"
TAP_REPO="Ekko0701/homebrew-kirby"
: "${KIRBY_SIGN_ID:?KIRBY_SIGN_ID 미설정 — 'Developer ID Application: 이름 (TEAMID)'}"
: "${KIRBY_NOTARY_PROFILE:?KIRBY_NOTARY_PROFILE 미설정 — notarytool store-credentials 프로필명}"

WORK="$(mktemp -d)"
ZIP="$WORK/Kirby-${VERSION}.zip"
trap 'rm -rf "$WORK"' EXIT

echo "▶︎ 1/7 Release 빌드…"
tuist generate --no-open
xcodebuild -workspace Kirby.xcworkspace -scheme Kirby -configuration Release \
  -destination 'platform=macOS,arch=arm64' build -quiet
SRC=$(/usr/bin/find ~/Library/Developer/Xcode/DerivedData -name 'Kirby.app' \
  -path '*Build/Products/Release*' 2>/dev/null | head -1)
[ -n "$SRC" ] || { echo "Release Kirby.app 없음"; exit 1; }
APP="$WORK/Kirby.app"; cp -R "$SRC" "$APP"

echo "▶︎ 2/7 Developer ID 서명(hardened runtime)…"
codesign --force --deep --options runtime --timestamp --sign "$KIRBY_SIGN_ID" "$APP"
codesign --verify --strict --verbose=2 "$APP"

echo "▶︎ 3/7 zip 후 공증 제출(대기)…"
ditto -c -k --keepParent "$APP" "$ZIP"
xcrun notarytool submit "$ZIP" --keychain-profile "$KIRBY_NOTARY_PROFILE" --wait

echo "▶︎ 4/7 스테이플 + 재압축…"
xcrun stapler staple "$APP"
rm -f "$ZIP"
ditto -c -k --keepParent "$APP" "$ZIP"

echo "▶︎ 5/7 sha256 계산…"
SHA=$(shasum -a 256 "$ZIP" | awk '{print $1}')
echo "   sha256=$SHA"

echo "▶︎ 6/7 GitHub Release 업로드…"
if gh release view "v$VERSION" -R "$REPO" >/dev/null 2>&1; then
  gh release upload "v$VERSION" "$ZIP" -R "$REPO" --clobber
else
  gh release create "v$VERSION" "$ZIP" -R "$REPO" -t "Kirby $VERSION" \
    -n "Kirby $VERSION — macOS cleanup utility"
fi

echo "▶︎ 7/7 Homebrew tap/cask 생성·갱신…"
gh repo view "$TAP_REPO" >/dev/null 2>&1 || \
  gh repo create "$TAP_REPO" --public -d "Homebrew tap for Kirby"
TAP_DIR="$WORK/tap"
git clone "https://github.com/$TAP_REPO.git" "$TAP_DIR" 2>/dev/null || true
mkdir -p "$TAP_DIR/Casks"
cat > "$TAP_DIR/Casks/kirby.rb" <<RUBY
cask "kirby" do
  version "$VERSION"
  sha256 "$SHA"

  url "https://github.com/$REPO/releases/download/v#{version}/Kirby-#{version}.zip"
  name "Kirby"
  desc "macOS cleanup utility (CleanMyMac-style)"
  homepage "https://github.com/$REPO"

  app "Kirby.app"

  zap trash: [
    "~/Library/Logs/Kirby",
  ]
end
RUBY
cd "$TAP_DIR"
git checkout -B main >/dev/null 2>&1
git add Casks/kirby.rb
git -c user.name="$(git config user.name)" -c user.email="$(git config user.email)" \
  commit -q -m "kirby $VERSION"
git push -u origin main

echo ""
echo "완료. 사용자 설치:"
echo "    brew tap $TAP_REPO"
echo "    brew install --cask kirby"
