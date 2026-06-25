# Kirby

macOS용 정리(cleanup) 유틸리티. CleanMyMac류 앱을 SwiftUI + Swift 6로 직접 만든 학습/개인
프로젝트입니다. 캐시·로그·휴지통·개발자 정크를 스캔해 **사용자 검토·확인 후** 안전하게 정리합니다.

## 핵심 원칙

> 스캔해서 보여주고, 사용자가 직접 선택하고, 명시적으로 확인해야만 지운다. 자동 삭제는 없다.

## 빠른 시작

```bash
tuist generate          # Project.swift → Kirby.xcworkspace 생성
# Xcode에서 ⌘R, 또는:
xcodebuild -workspace Kirby.xcworkspace -scheme Kirby \
  -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

> 실행하려면 macOS 시스템 설정에서 Kirby에 **전체 디스크 접근(FDA)** 권한을 켜야 합니다.

## 기술 스택

- 네이티브 macOS, SwiftUI, Swift 6 (Xcode 26, 배포 타깃 macOS 26)
- 비샌드박스 + Full Disk Access
- [Tuist](https://tuist.dev)로 프로젝트 생성
- Swift Testing으로 단위 테스트

## 청소 범주 (MVP)

| 범주 | 경로 |
|---|---|
| 사용자 캐시 | `~/Library/Caches` (위험 항목 제외) |
| 로그 | `~/Library/Logs` (7일 초과 기본 선택) |
| 휴지통 | `~/.Trash` |
| 개발자 정크 | DerivedData, npm/yarn/Homebrew 캐시 등 |

## 문서

개발자용 상세 문서는 [`docs/`](docs/)에 있습니다. [docs/00-overview.md](docs/00-overview.md)부터
읽으세요.

## 프로젝트 구조

```
Sources/
├── App/                앱 진입점·라우팅 (KirbyApp, RootView, Feature, AppState)
├── Features/
│   ├── Cleanup/         Models · Services(모듈/Coordinator) · Views
│   └── Onboarding/      FDA 권한 안내
└── Core/
    ├── Design/          색·간격·타이포·컴포넌트
    ├── FileManagement/  PathValidator · SizeCalculator · HardDeleter 등
    └── Utilities/       ByteFormat
Tests/                   단위 테스트 (안전·정확성 중심)
```

## 설계 결정

전체 계획과 결정 배경은 [`PLAN.md`](PLAN.md), 디자인 토큰은 [`DESIGN.md`](DESIGN.md) 참고.
