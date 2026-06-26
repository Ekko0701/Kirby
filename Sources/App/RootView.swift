import SwiftUI

/// 사이드바(기능 목록) + 디테일(선택 기능 화면) 셸.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        let selection = Binding<Feature?>(
            get: { appState.selectedFeature },
            set: { if let newValue = $0 { appState.selectedFeature = newValue } }
        )
        return NavigationSplitView {
            List(Feature.allCases, selection: selection) { feature in
                Label(feature.title, systemImage: feature.systemImage).tag(feature)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            switch appState.selectedFeature {
            case .cleanup: CleanupGate()
            }
        }
    }
}
