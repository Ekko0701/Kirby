import Foundation

/// ~/Library/Logs 정리. 7일 넘은 항목을 기본 선택한다.
struct LogsCleaner: CleanerModule {
    let id = "logs"
    let category = ScanCategory.logs
    let displayName = "로그"

    func scan(at root: String) async throws -> [ScanItem] {
        ChildScanner.items(
            root: root + "/Library/Logs",
            category: .logs,
            defaultSelected: true,
            isSafe: true,
            olderThanDays: 7
        )
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary {
        HardDeleter.clean(items)
    }
}
