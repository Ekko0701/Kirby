import Foundation

/// 대용량(>100MB) 또는 오래된(1년+) 파일. 사용자 데이터이므로 절대 자동 선택하지 않는다.
struct LargeOldCleaner: CleanerModule {
    let id = "largeOld"
    let category = ScanCategory.largeOld
    let displayName = "대용량·오래된 파일"

    static let minSizeBytes: Int64 = 100 * 1024 * 1024
    static let oldThresholdDays = 365
    static let maxItems = 200
    static let scanDirs = ["Downloads", "Documents", "Desktop", "Movies", "Music"]

    func scan(at root: String) async throws -> [ScanItem] {
        let found = Self.collect(root: root)
        return Array(found.sorted { $0.sizeBytes > $1.sizeBytes }.prefix(Self.maxItems))
    }

    /// 동기 순회(async 컨텍스트에서 enumerator의 makeIterator를 피하려 분리).
    private static func collect(root: String) -> [ScanItem] {
        let fm = FileManager.default
        let keys: Set<URLResourceKey> = [
            .totalFileAllocatedSizeKey, .contentModificationDateKey,
            .isRegularFileKey, .isSymbolicLinkKey,
        ]
        var found: [ScanItem] = []
        for dir in scanDirs {
            if Task.isCancelled { break }
            let base = URL(fileURLWithPath: root + "/" + dir)
            guard let enumerator = fm.enumerator(
                at: base, includingPropertiesForKeys: Array(keys),
                options: [.skipsHiddenFiles], errorHandler: { _, _ in true }
            ) else { continue }
            while let url = enumerator.nextObject() as? URL {
                if Task.isCancelled { break }
                guard let v = try? url.resourceValues(forKeys: keys) else { continue }
                if v.isSymbolicLink == true { enumerator.skipDescendants(); continue }
                guard v.isRegularFile == true else { continue }
                let size = Int64(v.totalFileAllocatedSize ?? 0)
                let isOld = v.contentModificationDate.map {
                    Date().timeIntervalSince($0) > Double(oldThresholdDays) * 86_400
                } ?? false
                if size >= minSizeBytes || (isOld && size > 1_000_000) {
                    found.append(ScanItem(
                        path: url.path, displayName: url.lastPathComponent,
                        category: .largeOld, sizeBytes: size,
                        isSafeToDelete: false, isSelectedByDefault: false
                    ))
                }
            }
        }
        return found
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
