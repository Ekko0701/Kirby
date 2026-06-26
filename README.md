# Kirby

macOS용 정리(cleanup) 유틸리티. CleanMyMac류 앱을 SwiftUI + Swift 6로 직접 만든 학습/개인
프로젝트입니다. 캐시·로그·휴지통·개발자 정크를 스캔해 **사용자 검토·확인 후** 안전하게 정리합니다.

## 핵심 원칙

> 스캔해서 보여주고, 사용자가 직접 선택하고, 명시적으로 확인해야만 지운다. 자동 삭제는 없다.

## 설치 (Homebrew)

```bash
brew tap Ekko0701/homebrew-kirby
brew trust ekko0701/kirby      # 최신 Homebrew의 서드파티 tap 신뢰(1회)
brew install --cask kirby
```

Developer ID 서명 + Apple 공증을 거쳐 Gatekeeper 경고 없이 설치됩니다. 릴리스 절차는 [docs/09-homebrew-distribution.md](docs/09-homebrew-distribution.md) 참고.

## 빠른 시작 (소스 빌드)

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

## 청소 범주 (PureMac 스타일 10종)

| 범주 | 대상 | 기본 |
|---|---|---|
| 시스템 정크 | `~/Library/Logs`(7일+) · `/Library/Caches`(시스템) | 로그만 ✓ |
| 사용자 캐시 | `~/Library/Caches` (위험 항목 denylist 제외) | ✓ |
| AI 앱 | Ollama·LM Studio 로그/캐시 | ✓ |
| 메일 첨부 | Mail 다운로드 첨부 | ✓ |
| 휴지통 | `~/.Trash` | ✓ |
| Xcode 정크 | DerivedData·CoreSimulator Caches·Archives·CocoaPods | DerivedData/Caches ✓ |
| Homebrew 캐시 | `~/Library/Caches/Homebrew` (`HOMEBREW_CACHE` 존중) | ✓ |
| Node 캐시 | npm·yarn·pnpm store | ✓ |
| Docker 캐시 | `docker system prune` (미설치 시 비활성) | 해제 |
| 대용량·오래된 파일 | >100MB 또는 1년+ (사용자 폴더) | 해제(자동선택 안 함) |

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
