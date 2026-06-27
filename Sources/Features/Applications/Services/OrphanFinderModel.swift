import SwiftUI

@MainActor
@Observable
final class OrphanFinderModel {
    var orphans: [AppFileItem] = []
    var isScanning = false
    var hasScanned = false
    var summary: CleanSummary?

    func scan() {
        isScanning = true
        summary = nil
        Task {
            let installed = await Task.detached { AppInventory.installedBundleIDs() }.value
            let found = await Task.detached { OrphanScanner.scan(installedBundleIDs: installed) }.value
            orphans = found
            isScanning = false
            hasScanned = true
        }
    }

    func toggle(_ item: AppFileItem) {
        guard let index = orphans.firstIndex(where: { $0.id == item.id }) else { return }
        orphans[index].isSelected.toggle()
    }

    var selectedItems: [AppFileItem] { orphans.filter(\.isSelected) }
    var selectedBytes: Int64 { selectedItems.reduce(0) { $0 + $1.sizeBytes } }

    func deleteSelected() {
        let paths = selectedItems.map(\.path)
        guard !paths.isEmpty else { return }
        Task {
            let result = await Task.detached { TrashRemover.trash(paths) }.value
            summary = result
            let ids = Set(paths)
            orphans.removeAll { ids.contains($0.path) }
        }
    }

    func dismissSummary() { summary = nil }
}
