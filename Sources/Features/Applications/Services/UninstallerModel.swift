import SwiftUI

@MainActor
@Observable
final class UninstallerModel {
    var apps: [InstalledApp] = []
    var selected: InstalledApp?
    var related: [AppFileItem] = []
    var appSize: Int64 = 0
    var isScanning = false
    var summary: CleanSummary?

    func loadApps() {
        guard apps.isEmpty else { return }
        apps = AppInventory.installedApps()
    }

    func select(_ app: InstalledApp) {
        selected = app
        related = []
        summary = nil
        appSize = 0
        isScanning = true
        let path = app.path
        let bundleID = app.bundleID
        let name = app.name
        Task {
            let result = await Task.detached {
                (RelatedFileFinder.relatedItems(bundleID: bundleID, appName: name),
                 SizeCalculator.allocatedSize(atPath: path))
            }.value
            related = result.0
            appSize = result.1
            isScanning = false
        }
    }

    func toggle(_ item: AppFileItem) {
        guard let index = related.firstIndex(where: { $0.id == item.id }) else { return }
        related[index].isSelected.toggle()
    }

    var selectedRelatedBytes: Int64 { related.filter(\.isSelected).reduce(0) { $0 + $1.sizeBytes } }
    var totalRemoveBytes: Int64 { appSize + selectedRelatedBytes }

    func uninstall() {
        guard let app = selected else { return }
        let paths = [app.path] + related.filter(\.isSelected).map(\.path)
        Task {
            let result = await Task.detached { TrashRemover.trash(paths) }.value
            summary = result
            apps.removeAll { $0.id == app.id }
        }
    }

    func dismissSummary() {
        summary = nil
        selected = nil
        related = []
    }
}
