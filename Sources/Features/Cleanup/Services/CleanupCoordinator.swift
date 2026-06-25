import SwiftUI

/// 스캔/선택/청소 전체를 조정하는 메인 액터 상태 객체.
@MainActor
@Observable
final class CleanupCoordinator {
    private(set) var state: ScanState = .idle
    private(set) var items: [ScanItem] = []
    private(set) var summary: CleanSummary?

    private let modules: [any CleanerModule]
    private let root: String
    private var scanTask: Task<Void, Never>?

    init(modules: [any CleanerModule], root: String = NSHomeDirectory()) {
        self.modules = modules
        self.root = root
    }

    var itemsByCategory: [ScanCategory: [ScanItem]] {
        Dictionary(grouping: items, by: \.category)
    }

    var selectedItems: [ScanItem] { items.filter(\.isSelected) }
    var selectedBytes: Int64 { selectedItems.reduce(0) { $0 + $1.sizeBytes } }
    var totalBytes: Int64 { items.reduce(0) { $0 + $1.sizeBytes } }

    func scan() {
        scanTask?.cancel()
        state = .scanning(progress: 0)
        items = []
        summary = nil
        let modules = self.modules
        let root = self.root
        scanTask = Task { [weak self] in
            await self?.runScan(modules: modules, root: root)
        }
    }

    func cancelScan() {
        scanTask?.cancel()
        state = .idle
    }

    private func runScan(modules: [any CleanerModule], root: String) async {
        var collected: [ScanItem] = []
        let total = modules.count
        var done = 0
        await withTaskGroup(of: [ScanItem].self) { group in
            for module in modules {
                group.addTask {
                    (try? await module.scan(at: root)) ?? []
                }
            }
            for await result in group {
                if Task.isCancelled { break }
                collected.append(contentsOf: result)
                done += 1
                state = .scanning(progress: Double(done) / Double(max(total, 1)))
            }
        }
        if Task.isCancelled { return }
        items = collected.sorted { $0.sizeBytes > $1.sizeBytes }
        state = .scanned
    }

    func toggle(_ item: ScanItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isSelected.toggle()
    }

    func setSelected(_ isSelected: Bool, for category: ScanCategory) {
        for idx in items.indices where items[idx].category == category {
            items[idx].isSelected = isSelected
        }
    }

    func clean() {
        let selected = selectedItems
        guard !selected.isEmpty else { return }
        state = .cleaning(progress: 0)
        let modules = self.modules
        Task { [weak self] in
            await self?.runClean(selected: selected, modules: modules)
        }
    }

    private func runClean(selected: [ScanItem], modules: [any CleanerModule]) async {
        let byCategory = Dictionary(grouping: selected, by: \.category)
        var totalItems = 0
        var totalFreed: Int64 = 0
        var errors: [CleanItemError] = []
        let categories = max(byCategory.keys.count, 1)
        var done = 0
        for module in modules {
            guard let chunk = byCategory[module.category], !chunk.isEmpty else { continue }
            if let result = try? await module.clean(chunk) {
                totalItems += result.itemsCleaned
                totalFreed += result.bytesFreed
                errors.append(contentsOf: result.errors)
            }
            done += 1
            state = .cleaning(progress: Double(done) / Double(categories))
        }
        summary = CleanSummary(
            itemsCleaned: totalItems, bytesFreed: totalFreed,
            errors: errors, timestamp: Date()
        )
        let cleanedIDs = Set(selected.map(\.id))
        items.removeAll { cleanedIDs.contains($0.id) }
        state = .completed
    }

    func reset() {
        scanTask?.cancel()
        state = .idle
        items = []
        summary = nil
    }
}
