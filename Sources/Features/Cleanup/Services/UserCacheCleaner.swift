import Foundation

/// ~/Library/Caches 정리. 위험 폴더(denylist)는 제외한다.
struct UserCacheCleaner: CleanerModule {
    let id = "userCache"
    let category = ScanCategory.userCache
    let displayName = "사용자 캐시"

    func scan(at root: String) async throws -> [ScanItem] {
        ChildScanner.items(
            root: root + "/Library/Caches",
            category: .userCache, defaultSelected: true, isSafe: true,
            exclude: CacheDenylist.folderNames
        )
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
