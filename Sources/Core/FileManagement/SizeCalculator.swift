import Foundation

/// 폴더/파일의 디스크 할당 크기를 합산한다. 심볼릭 링크는 건너뛴다.
/// Task가 취소되면 빠르게 빠져나간다.
enum SizeCalculator {
    static let keys: Set<URLResourceKey> = [
        .totalFileAllocatedSizeKey, .isSymbolicLinkKey, .isRegularFileKey,
    ]

    static func allocatedSize(atPath path: String) -> Int64 {
        let url = URL(fileURLWithPath: path)

        if let values = try? url.resourceValues(forKeys: keys) {
            if values.isSymbolicLink == true { return 0 }
            if values.isRegularFile == true {
                return Int64(values.totalFileAllocatedSize ?? 0)
            }
        }

        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: Array(keys),
            options: [],
            errorHandler: { _, _ in true }
        ) else { return 0 }

        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            if Task.isCancelled { break }
            guard let values = try? fileURL.resourceValues(forKeys: keys) else { continue }
            if values.isSymbolicLink == true {
                enumerator.skipDescendants()
                continue
            }
            if values.isRegularFile == true {
                total += Int64(values.totalFileAllocatedSize ?? 0)
            }
        }
        return total
    }
}
