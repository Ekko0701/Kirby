import SwiftUI

/// 앱 전역 상태. Cleanup 코디네이터를 한 곳에서 소유해 Dashboard와 각 범주 화면이 공유한다.
@MainActor
@Observable
final class AppState {
    var selectedItem: SidebarItem = .dashboard
    let cleanup = CleanupCoordinator(modules: DefaultCleanerModules.all())

    /// 정리(삭제)가 진행 중이면 true. 진행 중에는 사이드바 이동을 막는다.
    var isCleaning = false
}
