# Kirby — macOS Cleanup 유틸리티 (MVP) 구현 계획

> 앱/타깃/번들 이름: **Kirby**. 작업 폴더: `/Users/kimdongjoo/Desktop/Kirby` (구 `Vacuum`).
> 디자인 토큰 원본: `./DESIGN.md` (Cohere 에디토리얼 디자인 시스템).
> 본 문서는 계획 리뷰(2026-06-25) 후 확정 결정을 반영한 버전입니다.

## Context

CleanMyMac류 macOS 정리 유틸리티. 학습·개인 프로젝트. MVP는 **Cleanup 기능만** 구현, 이후
언인스톨러/대용량 파일/보호 등을 모듈로 확장.

확정된 핵심 결정:
- **플랫폼**: 네이티브 macOS, SwiftUI, Swift 6.x (Xcode 26.x / macOS 26). 배포 타깃 macOS 26.0.
- **배포**: GitHub 직접 배포, **비샌드박스**. 사용자가 켜는 **Full Disk Access(FDA)** 사용.
  평범한 `FileManager` 사용(security-scoped bookmark 불필요).
- **프로젝트 도구**: **Tuist** (`Project.swift` → `.xcodeproj` 생성). mise shim 경유 설치 확인됨.
- **MVP 청소 범주 4개**: 사용자 캐시, 로그, 휴지통 비우기, 개발자 정크.
- **UX 안전 원칙**: 스캔 → 범주별 결과(용량) → 검토·선택(위험 항목 기본 해제) → 명시적 "Clean" →
  진행률 → 요약. 자동 삭제 절대 없음.

## 리뷰 확정 결정 (2026-06-25)

### 결정 1 — 삭제 방식: **하드 삭제로 통일 (removeItem)**
- 4개 범주 모두 `FileManager.removeItem`으로 즉시 삭제 → 한 번의 Clean으로 용량 즉시 확보.
- Clean 직전 **명시적 확인 다이얼로그 필수**: "N개 항목, 총 X GB를 영구 삭제합니다. 복구할 수
  없습니다." + 범주별 요약.
- `CleanSummary.bytesFreed` = 실제 회수 용량(정확).
- **삭제 manifest 로깅(권장)**: 삭제 경로 목록을 앱 로그(예: `~/Library/Logs/Kirby/clean-*.log`)에
  기록 → 사고 추적용. 하드 삭제의 핵심 안전 보완책.
- 복구 불가이므로 `PathValidator`가 모든 `removeItem` 직전 **무조건** 통과해야 함.

### 결정 2 — 캐시 안전: **소규모 denylist**
- `Core/FileManagement/CacheDenylist.swift` — 알려진 위험 캐시 폴더명 집합:
  `CloudKit`, `com.apple.bird`, `com.apple.cloudd`, `com.apple.cloudkit`, `FamilyCircle`,
  `com.apple.Safari.SafeBrowsing` 등(동기화/재생성 불가 데이터).
- `CachesCleaner`는 denylist 매칭 항목을 **스캔 결과에서 제외**(MVP 단순성).
- denylist는 데이터로 분리해 추후 확장.

### 결정 3 — 카테고리 확장: **큐레이션된 카테고리만 (임의 폴더 청소 제외)**
- 사용자가 "추가로 청소할 카테고리"를 **선택**할 수 있게 하되, 후보는 전부 **미리 검증된 알려진
  안전 경로**로 한정. 사용자가 임의 폴더(Finder 선택 등)를 지정해 삭제하는 기능은 **MVP 범위 밖**
  (안전 지식이 없는 임의 경로 하드 삭제는 사고 위험 큼).
- 따라서 **하드 삭제 통일 유지** — 카테고리별 삭제 전략 분기(`deleteStrategy`)는 도입하지 않음.
- 아키텍처상 새 카테고리 = 새 `CleanerModule` 구현 + `modules` 배열 추가(뷰 변경 불필요).
  사용자는 카테고리 단위로 on/off 선택.
- **확장 후보**(점진 추가, 모두 알려진 안전 경로 / 재생성 가능): 브라우저 캐시(Chrome/Safari/
  Firefox 개별), 메일 다운로드 첨부(`~/Library/Containers/com.apple.mail/.../Downloads`),
  Xcode `iOS DeviceSupport`/`watchOS DeviceSupport`, 언어 파일(`.lproj`), 시스템 캐시 일부.
  → 위험·재생성 불가 경로는 추가 금지(결정 2 denylist 원칙 동일 적용).

### 추가 리뷰 반영
- **CoreSimulator**: 삭제 대상은 `~/Library/Developer/CoreSimulator/Caches`만.
  `.../Devices`(시뮬레이터 본체)는 **절대 제외** — PathValidator denylist에도 추가.
- **취소/성능**: 스캔 enumerator 루프에 `Task.checkCancellation()`, 자식 폴더별 크기 계산
  `TaskGroup` 병렬화, 스캔 진행률 노출.
- **부분 실패 UX**: `CleanSummary.errors` → 요약 화면에 "M개 항목 건너뜀(사용 중/권한)" 표기.
- **배포**: 배포 시 **Developer ID 서명 + notarize + staple** 필요(Gatekeeper). 개발 중엔
  안정적 ad-hoc 서명(FDA 재부여 최소화).
- **APFS 스냅샷/클론**: "확보 용량"은 추정치일 수 있음(주석 수준 인지).

## 설계 보정(블루프린트 대비)

- **스캔 단위 = 최상위 자식 폴더별 1 항목**(파일별 X). 각 루트의 immediate child를 하나의
  `ScanItem`으로 집계. 크기는 후손 전체를 `enumerator`로 합산하되 자식별 병렬화.
- **크기 계산**: `FileManager.enumerator(at:includingPropertiesForKeys:
  [.totalFileAllocatedSizeKey, .isSymbolicLinkKey, .isRegularFileKey])`로 순회, **할당 크기**
  합산, 심볼릭 링크 건너뜀.
- **색상 네임스페이스 충돌 회피**: `Color.primary` 충돌 → `Theme` enum 또는
  `Color.brandInk`/`brandPrimary` 고유 이름.
- **라이트 외형 고정**: `.preferredColorScheme(.light)`로 디자인 일관성 유지.
- **루트 경로 주입**: 모든 모듈 `scan(at root:)`/`clean`은 홈 경로 주입 → 임시 디렉터리 테스트.

## 아키텍처 (확장 가능한 모듈 구조)

핵심 추상화 (`Core/Architecture`):
- `protocol CleanerModule: Sendable` — `id`, `displayName`, `icon`(SF Symbol),
  `func scan(at root: String) async throws -> [ScanItem]`,
  `func clean(_ items: [ScanItem]) async throws -> CleanSummary`
- `struct ScanItem: Identifiable, Sendable` — `id, path, displayName, category, sizeBytes,
  isSafeToDelete, isSelectedByDefault`
- `enum ScanCategory` — `.cache / .logs / .trash / .developerJunk`
- `struct CleanSummary: Sendable` — `itemsCleaned, bytesFreed, errors, timestamp`
- `enum CleanError: Error, Sendable`

조정자: `@MainActor @Observable final class CleanupCoordinator` — `modules: [CleanerModule]`를
`TaskGroup` 병렬 스캔, 범주별 집계, `ScanState`(idle/scanning/scanned/cleaning/completed/failed),
선택 상태 보관, 취소 지원, `clean()` 수행.

데이터 흐름: FDA 체크 → (미허용 시) 온보딩 → 스캔(취소 가능) → 결과/선택 → 확인 다이얼로그 →
Clean(하드 삭제 + manifest) → 진행률 → 요약.

**미래 기능 seam**: 최상위 `enum Feature`(현재 `.cleanup`만). 새 범주 = 새 `CleanerModule` +
`modules` 배열 추가(뷰 불변). 새 최상위 기능 = `Feature` 케이스 + 코디네이터/뷰 추가.

동시성: 모든 I/O `async/await`, 병렬 스캔 `TaskGroup`, UI 상태 `@MainActor` + `@Observable`,
경계 모델 `Sendable`, 스캔 취소 `Task.checkCancellation()`.

## 안전 가드 (`Core/FileManagement/PathValidator.swift`)

모든 `removeItem` 직전 호출(복구 불가이므로 필수):
1. `standardizingPath` 후 대상이 **화이트리스트 루트 내부**인지 확인(아니면 거부).
2. 심볼릭 링크가 루트 밖을 가리키면 거부.
3. 시스템/위험 경로 접두사 거부: `/System`, `/usr`, `/bin`, `~/Library/Preferences`,
   `~/Library/Application Support`, `~/Library/Developer/CoreSimulator/Devices` 등.
4. 루트 자신은 삭제 금지(내용만 삭제).

## 범주별 구현 노트 (`Features/Cleanup/Services`)

- **CachesCleaner** — 루트 `~/Library/Caches`, 자식 폴더별 집계, **denylist 제외**, 기본 선택 ✓,
  `removeItem`.
- **LogsCleaner** — 루트 `~/Library/Logs`, 자식별 집계, 7일 초과 기본 선택, `removeItem`.
- **TrashCleaner** — `~/.Trash`(+ 가능 시 볼륨별 `/.Trashes`), 기본 선택 ✓, 하드 삭제로 비움.
- **DeveloperJunkCleaner** — 루트: DerivedData(✓), `CoreSimulator/Caches`(✓), `~/.npm`(✓),
  `~/.yarn/cache`(✓), `~/Library/Caches/Homebrew`(✓), `~/.cocoapods`(기본 해제),
  Xcode `Archives`(기본 해제). 각 루트 자식별 집계, `removeItem`. (`CoreSimulator/Devices` 제외)

## FDA 권한 흐름 (`Features/Onboarding`)

- `PermissionChecker.hasFullDiskAccess()` — 보호 경로(예: `~/Library/Safari`)
  `contentsOfDirectory` 시도 → 실패 시 미허용. (공식 API 없음, 프로브 방식)
- `requestFullDiskAccess()` — `NSWorkspace.shared.open(URL(string:
  "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)`.
- `OnboardingView` — 설명 + "시스템 설정 열기" pill + "권한을 켰어요"(재확인) 버튼.
- 주의: FDA는 코드서명 신원+경로 기준 → 리빌드 시 권한 풀릴 수 있음(안정적 ad-hoc 서명으로 완화).

## 디자인 토큰 → SwiftUI (`Core/Design`)

- `Colors.swift` — `Theme` 네임스페이스: brandInk(#212121), brandPrimary(#17171c),
  deepGreen(#003c33), coral(#ff7759), canvas(#fff), softStone(#eeece7), hairline(#d9d9dd),
  actionBlue(#1863dc), errorRed(#b30000), onDark(#fff). 명시적 `Color(red:green:blue:)`.
- `Spacing.swift` — `enum Spacing`(xxs2 … section80), `enum Radius`(xs4/sm8/md16/lg22/xl30/pill32).
- `Typography.swift` — `enum VFont` SF Pro 폴백(heroDisplay96 … micro12, monoLabel `.monospaced`).
- `Components/` — `PillButton`(primary/secondary), `SurfaceCard`, `FeatureBand`(딥그린 밴드),
  `CategoryRow`, 체크박스 항목 행, 스캔 진행 비주얼, 확인 다이얼로그.

## 파일/폴더 구조 (피처 기반, <400줄)

```
Kirby/
├── Project.swift, Tuist/(설정), 생성 산출물 .gitignore
├── Sources/
│   ├── App/            KirbyApp.swift, Feature.swift, AppState.swift
│   ├── Features/
│   │   ├── Cleanup/
│   │   │   ├── Views/     CleanupView, ScanResultsView, ConfirmDeleteDialog,
│   │   │   │              CleanProgressView, SummaryView
│   │   │   ├── Models/    ScanItem, ScanCategory, ScanState, CleanSummary, CleanError
│   │   │   └── Services/  CleanupCoordinator, CleanerModule,
│   │   │                  Caches/Logs/Trash/DeveloperJunkCleaner
│   │   └── Onboarding/ Views/OnboardingView, PermissionChecker
│   ├── Core/
│   │   ├── Design/     Colors, Spacing, Typography, Components/*
│   │   ├── FileManagement/ PathValidator, SizeCalculator, FileOperations,
│   │   │                   CacheDenylist, DeleteManifest
│   │   └── Utilities/  ByteFormatter, Sendable+Extensions
│   └── Resources/      Info.plist, Assets, Localizable.strings
└── Tests/  CleanupTests/*, FileManagementTests/*, UtilitiesTests/* (KirbyTests 타깃)
```

## Tuist 구성 (`Project.swift`)

- macOS 앱 타깃 1개 + 단위 테스트 타깃 1개.
- `deploymentTargets: .macOS("26.0")`.
- **샌드박스 비활성**(App Sandbox 엔타이틀먼트 미추가). FDA는 사용자가 시스템 설정에서 부여.
- Info.plist: 버전/카피라이트, `ITSAppUsesNonExemptEncryption=false`, `LSMinimumSystemVersion`.
- 개발: 안정적 ad-hoc 서명. 배포: Developer ID 서명 + notarize + staple.
- 사전 준비: `tuist`(mise) 확인 → `tuist generate`.

## 빌드 순서 (단계별 독립 검증)

1. **Tuist 스캐폴딩 + 디자인 토큰/컴포넌트** — `tuist generate` 성공, 컴포넌트 Preview 렌더.
2. **코어 아키텍처** — 모델/프로토콜/`CleanupCoordinator`/`PathValidator`/`CacheDenylist`/
   `ByteFormatter`/`DeleteManifest`. `bytesFreed` = 하드삭제 실제 회수량으로 확정.
   단위 테스트(PathValidator, ByteFormatter, SizeCalculator, CacheDenylist).
3. **스캔 모듈 4종(스캔만)** — 임시 디렉터리 픽스처로 각 모듈 단위 테스트(취소 포함).
4. **뷰 & 플로우** — Onboarding/Cleanup/ScanResults/확인 다이얼로그/CleanProgress/Summary.
5. **Clean 구현** — `removeItem` + manifest 로깅 + 진행률. 임시 디렉터리 삭제 단위 테스트.
6. **폴리시 & 안전** — 에러/부분 실패 메시지, 포커스 기본값, 접근성 라벨, 코드/디자인 리뷰.
   (배포 시점에 서명·공증 단계 수행.)

## 테스트/검증 (목표 80% 단위 커버리지)

- **단위(자동)**: `PathValidator`(루트 밖/시스템 경로/Devices 거부), `CacheDenylist`(제외 동작),
  `SizeCalculator`(픽스처 트리 합계), 각 `CleanerModule.scan`(임시 루트, 항목 수/플래그),
  `ByteFormatter`, Clean의 `removeItem`(임시 픽스처 삭제 확인).
- **수동 E2E**:
  1. FDA: `tccutil reset SystemPolicyAllFiles` → 온보딩 노출 → 허용 후 진입.
  2. 스캔: `/tmp/kirby-test/...`에 더미 생성 후 루트 주입 → 용량/취소 확인.
  3. Clean: 픽스처 하드 삭제 → 사라짐 + manifest 기록 확인. 휴지통 범주 비우기 확인.
  4. 디자인: pill 32px/니어블랙, 카드 8–22px/헤어라인, 라이트 외형, 토큰값 일치.

## 참고 규칙 파일 (준수)

- `~/.claude/rules/swift/coding-style.md`, `~/.claude/rules/swift/patterns.md`
- `~/.claude/rules/common/coding-style.md` (불변성, 작은 파일, 매직넘버 금지)
- `~/.claude/rules/web/design-quality.md` (안티-템플릿, 의도된 위계/리듬)
- `/Users/kimdongjoo/Desktop/Kirby/DESIGN.md` (토큰 원본)
