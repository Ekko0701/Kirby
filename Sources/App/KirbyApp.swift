import SwiftUI

@main
struct KirbyApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .frame(minWidth: 940, minHeight: 640)
                .preferredColorScheme(.light)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
    }
}
