import Foundation

/// Node 패키지 매니저 캐시: npm, yarn(classic), pnpm content-addressable store.
struct NodeCleaner: CleanerModule {
    let id = "node"
    let category = ScanCategory.node
    let displayName = "Node 캐시"

    static let relativeRoots = [
        ".npm",
        ".yarn/cache",
        "Library/pnpm/store",
        ".local/share/pnpm/store",
    ]

    func scan(at root: String) async throws -> [ScanItem] {
        var all: [ScanItem] = []
        for rel in Self.relativeRoots {
            if Task.isCancelled { break }
            all += ChildScanner.items(
                root: root + "/" + rel, category: .node, defaultSelected: true, isSafe: true
            )
        }
        return all
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
