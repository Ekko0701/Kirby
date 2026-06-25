# 시작하기 — 빌드하고 실행하기

> 처음 클론한 사람이 앱을 띄우기까지의 과정입니다.

## 필요한 것

| 도구 | 버전(개발 기준) | 용도 |
|---|---|---|
| macOS | 26 이상 | 배포 타깃이 26.0 |
| Xcode | 26.x | 컴파일러·SDK |
| Tuist | 4.x | Xcode 프로젝트 생성 |

Tuist는 보통 `mise`로 설치합니다. 이미 깔려 있는지 확인:

```bash
tuist version
```

## 프로젝트 생성 (가장 먼저 할 일)

이 저장소에는 `.xcodeproj`가 **없습니다**. 대신 `Project.swift`로부터 생성합니다:

```bash
tuist generate
```

성공하면 `Kirby.xcworkspace`가 생기고 Xcode가 열립니다. (`--no-open`을 붙이면 안 엽니다.)

```mermaid
flowchart LR
    P["Project.swift<br/>(코드로 쓴 설정)"] -->|tuist generate| W["Kirby.xcworkspace<br/>(생성물)"]
    W --> X["Xcode에서 빌드·실행"]
```

> ⚠️ `.xcodeproj` / `.xcworkspace`는 생성물이라 `.gitignore`에 들어 있습니다. 직접 수정하지 말고
> 항상 `Project.swift`를 고친 뒤 다시 `tuist generate` 하세요.

## 명령줄에서 빌드

```bash
xcodebuild -workspace Kirby.xcworkspace -scheme Kirby \
  -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

## 테스트 실행

```bash
xcodebuild -workspace Kirby.xcworkspace -scheme Kirby \
  -destination 'platform=macOS,arch=arm64' test
```

테스트는 Swift Testing(`import Testing`, `@Test`, `#expect`)을 씁니다. XCTest가 아닙니다.

## 코드 서명에 대해

개발 중에는 ad-hoc 서명(`CODE_SIGN_IDENTITY = "-"`)을 씁니다. 별도 개발자 계정 없이 로컬에서
돌리기 위함입니다. 배포 시점에는 Developer ID 서명 + 공증(notarization)이 필요합니다(추후 문서화).
