import SwiftUI

/// 앱 전역 상태. Cleanup 코디네이터를 한 곳에서 소유해 Dashboard 분석과 Cleanup이 공유한다.
@MainActor
@Observable
final class AppState {
    var selectedFeature: Feature = .dashboard
    let cleanup = CleanupCoordinator(modules: DefaultCleanerModules.all())
}
