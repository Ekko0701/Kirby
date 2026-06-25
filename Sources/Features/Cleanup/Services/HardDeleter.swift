import Foundation

/// 선택된 항목을 영구 삭제하는 공용 로직(결정 1: 하드 삭제 통일).
///
/// 허용 루트는 각 항목의 부모 폴더로 자동 도출한다(항목은 우리 스캐너가 만든 직계 자식이므로
/// 부모 = 스캔 루트). PathValidator가 시스템 경로/루트 자신/심링크 탈출을 추가로 막는다.
enum HardDeleter {
    static func clean(
        _ items: [ScanItem],
        manifest: DeleteManifest = DeleteManifest()
    ) -> CleanSummary {
        let roots = Array(Set(items.map { ($0.path as NSString).deletingLastPathComponent }))
        let validator = PathValidator(allowedRoots: roots)
        let ops = FileOperations(validator: validator)

        var cleaned = 0
        var freed: Int64 = 0
        var errors: [CleanItemError] = []
        var deletedPaths: [String] = []

        for item in items {
            if Task.isCancelled { break }
            do {
                try ops.remove(path: item.path)
                cleaned += 1
                freed += item.sizeBytes
                deletedPaths.append(item.path)
            } catch {
                errors.append(CleanItemError(path: item.path, message: String(describing: error)))
            }
        }

        manifest.record(paths: deletedPaths, at: Date())
        return CleanSummary(
            itemsCleaned: cleaned, bytesFreed: freed,
            errors: errors, timestamp: Date()
        )
    }
}
