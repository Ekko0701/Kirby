# 배포 — GitHub로 내보내기 (비샌드박스 앱)

> 로컬에서 돌리는 것과, 남에게 배포하는 것은 요구사항이 다릅니다.

## 개발 중(로컬)

ad-hoc 서명(`CODE_SIGN_IDENTITY = "-"`)으로 충분합니다. 별도 개발자 계정이 없어도 됩니다.

## 배포 시(다른 사람 Mac에서 실행)

비샌드박스 앱을 그냥 올리면 Gatekeeper가 "손상되어 열 수 없음"으로 막습니다. 그래서 3단계가
필요합니다:

```mermaid
flowchart LR
    A[Developer ID로 서명] --> B[Apple에 공증 제출<br/>notarize]
    B --> C[티켓 스테이플<br/>staple]
    C --> D[.dmg/.zip 배포]
```

1. **서명**: `codesign --options runtime --sign "Developer ID Application: ..." Kirby.app`
2. **공증**: `xcrun notarytool submit Kirby.zip --apple-id ... --wait`
3. **스테이플**: `xcrun stapler staple Kirby.app`

> 이 단계는 유료 Apple Developer Program 계정이 필요합니다. MVP를 본인 Mac에서만 쓸 거라면
> 건너뛰어도 됩니다.

## Info.plist 핵심 값

| 키 | 값 | 이유 |
|---|---|---|
| `LSMinimumSystemVersion` | 26.0 | 배포 타깃 |
| `ITSAppUsesNonExemptEncryption` | false | 수출 규정(암호화 안 씀) |
| `LSApplicationCategoryType` | utilities | App 카테고리 |

## 샌드박스는?

**끕니다.** App Sandbox 엔타이틀먼트를 추가하지 않습니다. 대신 사용자가 FDA를 켭니다
([06-fda-permissions.md](06-fda-permissions.md) 참고).
