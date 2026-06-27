# 아키텍처 — 화면과 청소는 어떻게 흐르나

> "버튼을 누르면 코드가 어디서 어디로 흘러가지?"를 따라가는 문서입니다.

## 큰 그림: 네비게이션 + 3개의 층

좌측 인스펙터(`SidebarItem`)가 무엇을 보여줄지 정하고, 그 아래는 뷰 → 조정자 → 모듈 3층입니다.

```mermaid
flowchart TD
    SB[RootView<br/>섹션형 사이드바] -->|SidebarItem| DASH[DashboardView]
    SB -->|category| CAT[CategoryCleanupView]
    SB -->|installedApps/orphanedFiles| APPS[Applications 화면]
    SB -->|purgeable| PURGE[PurgeableSpaceView]

    DASH --> CC[CleanupCoordinator<br/>@MainActor]
    CAT --> CC
    CC --> M[청소 모듈 10종<br/>SystemJunk·UserCache·…·Docker·LargeOld]
    M --> FS[(파일 시스템 / docker CLI)]
```

- **뷰**는 그리기만 한다. 로직을 갖지 않는다.
- **Coordinator**는 상태(state)와 항목(items)을 들고 모듈을 호출한다. 메인 액터 전용.
- **모듈**은 실제 파일 작업(스캔/삭제)을 한다. 서로 독립적이라 병렬로 돈다.

## 네비게이션: `SidebarItem` / `SidebarSection`

사이드바는 3개 섹션(OVERVIEW / APPLICATIONS / CLEANUP)으로 나뉘고, 각 항목이 `SidebarItem`입니다.

```swift
enum SidebarItem: Hashable, Identifiable {
    case dashboard
    case installedApps          // APPLICATIONS
    case orphanedFiles
    case category(ScanCategory) // CLEANUP — 범주별 항목
    case purgeable
}
```

`RootView`는 선택된 `SidebarItem`에 따라 디테일 뷰를 분기합니다. 새 최상위 화면은 case를 더하고
`SidebarSection.items`에 넣으면 사이드바·라우팅이 확장됩니다.

## 핵심 추상화: `CleanerModule`

청소 가능한 "한 범주"를 표현하는 프로토콜입니다. 딱 두 가지만 할 줄 알면 됩니다:

```swift
protocol CleanerModule: Sendable {
    var category: ScanCategory { get }
    func scan(at root: String) async throws -> [ScanItem]   // 후보 찾기
    func clean(_ items: [ScanItem]) async throws -> CleanSummary  // 삭제
}
```

> 💡 `scan(at root:)`이 홈 경로(`root`)를 **인자로 받는** 점이 중요합니다. 실제 앱에서는
> `NSHomeDirectory()`를 넣지만, 테스트에서는 임시 폴더를 넣어 실제 홈을 건드리지 않고 검증합니다.

## 공유 코디네이터 + 범주별 청소

`AppState`가 `CleanupCoordinator` 하나를 소유합니다. Dashboard가 진입 시 전체 스캔(`ensureScanned`)을
돌리고, 각 `CategoryCleanupView`는 같은 코디네이터의 **그 범주 슬라이스**만 보여주고 정리합니다.

```swift
coordinator.items(in: .userCache)          // 그 범주 항목
coordinator.selectedBytes(in: .userCache)  // 선택 용량
await coordinator.clean(category: .userCache)  // 그 범주만 삭제
```

전체 스캔은 공유, 정리는 범주별로 독립이라 각 범주 화면이 서로 간섭하지 않습니다.

## 병렬 스캔

여러 모듈을 동시에 스캔하려고 `TaskGroup`을 씁니다:

```swift
await withTaskGroup(of: [ScanItem].self) { group in
    for module in modules {
        group.addTask { (try? await module.scan(at: root)) ?? [] }
    }
    for await result in group {
        collected.append(contentsOf: result)   // 메인 액터에서 안전하게 합산
    }
}
```

모듈은 `Sendable`이라 액터 경계를 안전하게 넘나듭니다. 결과를 모으는 일은 메인 액터에서
일어나므로 경쟁 상태(data race)가 없습니다.

## 왜 이렇게 나눴나 (확장성)

- **새 청소 범주**: `ScanCategory`에 case 추가 + `CleanerModule` 구현 1개 + `DefaultCleanerModules.all()`
  등록. 사이드바 CLEANUP 섹션·Dashboard 도넛이 자동 반영(`SidebarSection`/색상 맵에만 추가).
- **새 최상위 화면**: `SidebarItem` case + `SidebarSection.items` + `RootView` 분기.

다음: [04-cleaner-modules.md](04-cleaner-modules.md)
