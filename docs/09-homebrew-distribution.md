# Homebrew로 배포하기 (brew install --cask kirby)

> 목표: 사용자가 `brew tap Ekko0701/homebrew-kirby` 후 `brew install --cask kirby`로 설치.

## 큰 그림

Homebrew **cask**는 소스가 아니라 **빌드된 `.app`을 zip으로 다운로드**해 설치합니다.
그래서 (1) 서명·공증된 앱을 GitHub Release에 올리고, (2) 그 URL+sha256을 담은 cask 파일을
(3) **tap 저장소**(`homebrew-kirby`)에 둬야 합니다.

```mermaid
flowchart LR
    A[Release 빌드] --> B[Developer ID 서명]
    B --> C[공증 notarytool]
    C --> D[staple + zip]
    D --> E[GitHub Release 업로드]
    E --> F[tap의 Casks/kirby.rb<br/>version·url·sha256]
    F --> G[brew install --cask kirby]
```

이 전 과정을 `scripts/release.sh`가 한 번에 수행합니다.

## 왜 공식 `brew install --cask kirby`(맨이름)가 바로 안 되나

맨이름은 공식 `homebrew/cask` 저장소에 등록돼야 동작하는데, 공식 등록은 **공증·안정성·인지도**
요건이 있어 신규 개인 프로젝트는 사실상 불가합니다. 대신 **개인 tap**을 쓰면 한 번
`brew tap Ekko0701/homebrew-kirby` 후 동일하게 `brew install --cask kirby`가 됩니다.

## 사전 준비 (최초 1회)

### 1. Apple Developer Program
- 가입(연 $99). 공증(notarization)에 필수. 미가입 시 다른 Mac에서 Gatekeeper가 실행을 막습니다.

### 2. Developer ID Application 인증서
- Xcode → Settings → Accounts → 팀 선택 → Manage Certificates → `+` → **Developer ID Application**
- 또는 developer.apple.com → Certificates에서 생성 후 키체인에 설치.
- 인증서 이름 확인: `security find-identity -v -p codesigning` → `Developer ID Application: 이름 (TEAMID)`

### 3. 공증 자격증명 저장 (앱 암호)
- appleid.apple.com → 로그인 및 보안 → **앱 암호** 생성.
- 키체인 프로필로 저장:
  ```bash
  xcrun notarytool store-credentials KirbyNotary \
    --apple-id "you@email.com" --team-id "TEAMID" --password "앱-암호"
  ```

### 4. 환경변수
```bash
export KIRBY_SIGN_ID="Developer ID Application: Your Name (TEAMID)"
export KIRBY_NOTARY_PROFILE="KirbyNotary"
```

## 릴리스 (매 버전)

```bash
./scripts/release.sh 0.1.0
```

스크립트가 자동으로:
1. Release 빌드 → 2. Developer ID 서명(hardened runtime) → 3. zip 후 공증 제출(대기)
→ 4. staple + 재압축 → 5. sha256 → 6. `Ekko0701/Kirby`에 GitHub Release 업로드
→ 7. `Ekko0701/homebrew-kirby` tap 생성/갱신 + `Casks/kirby.rb` 푸시.

> tap 저장소가 없으면 스크립트가 `gh repo create`로 만듭니다(gh 로그인 필요).

## 사용자 설치

```bash
brew tap Ekko0701/homebrew-kirby
brew install --cask kirby
```

업데이트: 새 버전으로 `./scripts/release.sh 0.2.0` 실행 → 사용자는 `brew upgrade --cask kirby`.

## 현재 상태 / 남은 일

- 소스는 `Ekko0701/Kirby`에 푸시됨. ✅
- `scripts/release.sh`(파이프라인) 준비됨. ✅
- **남음**: Apple Developer 계정 + 인증서 + 공증 프로필 준비 후 `release.sh` 1회 실행.
  계정이 준비되면 위 사전 준비 1~4 → 릴리스 한 줄이면 `brew install --cask kirby`가 동작합니다.

## 무료로 먼저 테스트하려면 (공증 없이)

공증 전 ad-hoc 빌드를 cask로 시험하려면 서명/공증 단계를 건너뛴 zip을 Release에 올리고
cask에 같은 url/sha를 넣으면 설치는 됩니다. 단 실행 시 Gatekeeper가 막으므로 사용자가
`xattr -dr com.apple.quarantine /Applications/Kirby.app` 또는 우클릭→열기로 1회 허용해야 합니다.
(권장하지 않음 — 정식 경로는 공증.)
