import Foundation

/// 루트 볼륨의 디스크 사용량을 조회한다.
enum DiskSpace {
    static func current(at path: String = NSHomeDirectory()) -> DiskUsage {
        let url = URL(fileURLWithPath: path)
        let keys: Set<URLResourceKey> = [
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
        ]
        guard let values = try? url.resourceValues(forKeys: keys) else { return .empty }
        let total = Int64(values.volumeTotalCapacity ?? 0)
        let free = values.volumeAvailableCapacityForImportantUsage ?? 0
        return DiskUsage(total: total, free: free)
    }
}
