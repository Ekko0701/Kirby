import Foundation

/// 휴지통 비우기. 내장(~/.Trash) + 외장 볼륨(/Volumes/*/.Trashes/<uid>) 내용물을 영구 삭제.
struct TrashCleaner: CleanerModule {
    let id = "trash"
    let category = ScanCategory.trash
    let displayName = "휴지통"

    func scan(at root: String) async throws -> [ScanItem] {
        var items = ChildScanner.items(
            root: root + "/.Trash", category: .trash, defaultSelected: true, isSafe: true
        )
        let uid = getuid()
        let volumes = (try? FileManager.default.contentsOfDirectory(atPath: "/Volumes")) ?? []
        for volume in volumes {
            if Task.isCancelled { break }
            items += ChildScanner.items(
                root: "/Volumes/\(volume)/.Trashes/\(uid)",
                category: .trash, defaultSelected: true, isSafe: true,
                displayPrefix: volume
            )
        }
        return items
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
