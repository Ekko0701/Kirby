import Foundation

/// 시스템 정크: 사용자 로그(안전, 7일 초과 기본선택) + 시스템 캐시(/Library/Caches, 위험 → 기본 해제).
struct SystemJunkCleaner: CleanerModule {
    let id = "systemJunk"
    let category = ScanCategory.systemJunk
    let displayName = "시스템 정크"

    func scan(at root: String) async throws -> [ScanItem] {
        var items = ChildScanner.items(
            root: root + "/Library/Logs",
            category: .systemJunk, defaultSelected: true, isSafe: true, olderThanDays: 7
        )
        items += ChildScanner.items(
            root: "/Library/Caches",
            category: .systemJunk, defaultSelected: false, isSafe: false
        )
        return items
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
