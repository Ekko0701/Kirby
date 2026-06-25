import SwiftUI

/// 사이드바(기능 목록) + 디테일(선택 기능 화면)으로 구성된 최상위 셸.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        NavigationSplitView {
            List(Feature.allCases, selection: $appState.selectedFeature) { feature in
                Label(feature.title, systemImage: feature.systemImage)
                    .font(VFont.body16)
                    .tag(feature)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            switch appState.selectedFeature {
            case .cleanup:
                CleanupGate()
            }
        }
    }
}
