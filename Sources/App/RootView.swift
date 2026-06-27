import SwiftUI

/// 섹션형 사이드바(OVERVIEW/APPLICATIONS/CLEANUP) + 디테일 라우팅.
struct RootView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        let selection = Binding<SidebarItem?>(
            get: { appState.selectedItem },
            set: { if let newValue = $0 { appState.selectedItem = newValue } }
        )
        return NavigationSplitView {
            List(selection: selection) {
                ForEach(SidebarSection.allCases) { section in
                    Section(section.rawValue) {
                        ForEach(section.items) { item in
                            row(item)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AuroraBackground())
            .disabled(appState.isCleaning)          // 정리 중 사이드바 잠금
            .navigationSplitViewColumnWidth(min: 240, ideal: 260, max: 320)
        } detail: {
            detail(for: appState.selectedItem)
        }
    }

    @ViewBuilder
    private func row(_ item: SidebarItem) -> some View {
        if case .installedApps = item {
            Label(item.title, systemImage: item.systemImage)
                .badge(AppInventory.installedCount())
                .tag(item)
        } else {
            Label(item.title, systemImage: item.systemImage).tag(item)
        }
    }

    @ViewBuilder
    private func detail(for item: SidebarItem) -> some View {
        switch item {
        case .dashboard: DashboardView()
        case .installedApps: InstalledAppsView()
        case .orphanedFiles: OrphanedFilesView()
        case .purgeable: PurgeableSpaceView()
        case .category(let category):
            CategoryCleanupView(category: category, coordinator: appState.cleanup)
        }
    }
}
