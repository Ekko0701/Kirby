import SwiftUI

/// FDA 권한을 확인해 온보딩 또는 Cleanup 본 화면으로 분기한다.
struct CleanupGate: View {
    let coordinator: CleanupCoordinator
    @State private var hasAccess = PermissionChecker.hasFullDiskAccess()

    var body: some View {
        if hasAccess {
            CleanupView(coordinator: coordinator)
        } else {
            OnboardingView {
                hasAccess = PermissionChecker.hasFullDiskAccess()
            }
        }
    }
}
