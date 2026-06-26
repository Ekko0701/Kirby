import Testing
import Foundation
@testable import Kirby

private struct FakeModule: CleanerModule {
    let id = "fake"
    let category: ScanCategory
    let displayName = "fake"
    let produced: [ScanItem]

    func scan(at root: String) async throws -> [ScanItem] { produced }
    func clean(_ items: [ScanItem]) async throws -> CleanSummary {
        CleanSummary(itemsCleaned: items.count,
                     bytesFreed: items.reduce(0) { $0 + $1.sizeBytes },
                     errors: [], timestamp: Date())
    }
}

@MainActor
private func waitUntil(timeout: Double = 2.0, _ condition: () -> Bool) async throws {
    let start = Date()
    while !condition() {
        if Date().timeIntervalSince(start) > timeout { break }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
}

@MainActor
@Suite("CleanupCoordinator")
struct CleanupCoordinatorTests {
    private func makeItem(_ path: String) -> ScanItem {
        ScanItem(path: path, displayName: (path as NSString).lastPathComponent,
                 category: .userCache, sizeBytes: 100, isSafeToDelete: true, isSelectedByDefault: true)
    }

    @Test("스캔하면 항목이 모이고 상태가 scanned가 된다")
    func scanCollects() async throws {
        let coord = CleanupCoordinator(
            modules: [FakeModule(category: .userCache, produced: [makeItem("/tmp/x")])],
            root: "/tmp")
        coord.scan()
        try await waitUntil { coord.state == .scanned }
        #expect(coord.items.count == 1)
        #expect(coord.selectedBytes == 100)
    }

    @Test("clean하면 요약이 생기고 선택 항목이 비워진다")
    func cleanFlow() async throws {
        let coord = CleanupCoordinator(
            modules: [FakeModule(category: .userCache, produced: [makeItem("/tmp/y")])],
            root: "/tmp")
        coord.scan()
        try await waitUntil { coord.state == .scanned }
        coord.clean()
        try await waitUntil { coord.state == .completed }
        #expect(coord.summary?.itemsCleaned == 1)
        #expect(coord.items.isEmpty)
    }
}
