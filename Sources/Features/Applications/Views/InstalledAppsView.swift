import SwiftUI

/// 설치된 앱 목록. 앱을 고르면 관련 파일과 함께 휴지통으로 제거한다.
struct InstalledAppsView: View {
    @State private var model = UninstallerModel()

    var body: some View {
        NavigationStack {
            List(model.apps) { app in
                NavigationLink(value: app) {
                    HStack(spacing: Spacing.md12) {
                        Image(systemName: "app.dashed").foregroundStyle(Theme.actionBlue)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(app.name).font(VFont.body16).foregroundStyle(Theme.brandInk)
                            Text(app.bundleID ?? "—").font(VFont.micro12).foregroundStyle(Theme.muted)
                        }
                    }
                    .padding(.vertical, Spacing.xxs2)
                }
            }
            .navigationDestination(for: InstalledApp.self) { app in
                AppUninstallView(app: app, model: model)
            }
            .navigationTitle("Installed Apps (\(model.apps.count))")
        }
        .task { model.loadApps() }
    }
}
