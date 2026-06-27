import Foundation

/// 사용자 캐시. ~/Library/Caches 직계 + 샌드박스 앱 컨테이너의 캐시까지 포함.
/// 위험 폴더(denylist)는 제외한다.
struct UserCacheCleaner: CleanerModule {
    let id = "userCache"
    let category = ScanCategory.userCache
    let displayName = "사용자 캐시"

    func scan(at root: String) async throws -> [ScanItem] {
        var items = ChildScanner.items(
            root: root + "/Library/Caches",
            category: .userCache, defaultSelected: true, isSafe: true,
            exclude: CacheDenylist.folderNames
        )

        // 샌드박스 앱은 캐시를 컨테이너 안에 둔다: ~/Library/Containers/<id>/Data/Library/Caches
        let containersRoot = root + "/Library/Containers"
        let containers = (try? FileManager.default.contentsOfDirectory(atPath: containersRoot)) ?? []
        for container in containers {
            if Task.isCancelled { break }
            if CacheDenylist.isDenied(folderName: container) { continue }
            items += ChildScanner.items(
                root: containersRoot + "/" + container + "/Data/Library/Caches",
                category: .userCache, defaultSelected: true, isSafe: true,
                displayPrefix: container
            )
        }
        return items
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
