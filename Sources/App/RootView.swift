import SwiftUI

/// 사이드바(섹션별 기능 목록) + 디테일(선택 기능 화면) 셸.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        let selection = Binding<Feature?>(
            get: { appState.selectedFeature },
            set: { if let newValue = $0 { appState.selectedFeature = newValue } }
        )
        return NavigationSplitView {
            List(selection: selection) {
                ForEach(FeatureSection.allCases) { section in
                    Section(section.rawValue) {
                        ForEach(Feature.features(in: section)) { feature in
                            Label(feature.title, systemImage: feature.systemImage).tag(feature)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 300)
        } detail: {
            switch appState.selectedFeature {
            case .dashboard: DashboardView()
            case .cleanup: CleanupGate(coordinator: appState.cleanup)
            case .uninstaller: UninstallerView()
            case .orphanFinder: OrphanFinderView()
            }
        }
    }
}
