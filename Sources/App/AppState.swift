import SwiftUI

/// 앱 전역 상태. Cleanup 코디네이터를 한 곳에서 소유해 Dashboard와 각 범주 화면이 공유한다.
@MainActor
@Observable
final class AppState {
    var selectedItem: SidebarItem = .dashboard
    let cleanup = CleanupCoordinator(modules: DefaultCleanerModules.all())
}
