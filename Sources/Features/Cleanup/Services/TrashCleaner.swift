import Foundation

/// ~/.Trash 비우기. 내용물을 영구 삭제한다.
struct TrashCleaner: CleanerModule {
    let id = "trash"
    let category = ScanCategory.trash
    let displayName = "휴지통"

    func scan(at root: String) async throws -> [ScanItem] {
        ChildScanner.items(
            root: root + "/.Trash",
            category: .trash,
            defaultSelected: true,
            isSafe: true
        )
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary {
        HardDeleter.clean(items)
    }
}
