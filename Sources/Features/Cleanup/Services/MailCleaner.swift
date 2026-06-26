import Foundation

/// 메일 앱이 받은 첨부 다운로드 정리.
struct MailCleaner: CleanerModule {
    let id = "mail"
    let category = ScanCategory.mail
    let displayName = "메일 첨부"

    func scan(at root: String) async throws -> [ScanItem] {
        ChildScanner.items(
            root: root + "/Library/Containers/com.apple.mail/Data/Library/Mail Downloads",
            category: .mail, defaultSelected: true, isSafe: true
        )
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
