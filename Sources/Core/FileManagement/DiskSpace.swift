import Foundation

/// 루트 볼륨의 디스크 사용량/정리 가능 공간을 조회한다.
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

    /// 시스템이 관리하는 "비울 수 있는(purgeable)" 공간 추정치.
    /// 중요 용도 여유(여유+purgeable)에서 실제 여유를 뺀 값.
    static func purgeableEstimate(at path: String = NSHomeDirectory()) -> Int64 {
        let url = URL(fileURLWithPath: path)
        let keys: Set<URLResourceKey> = [
            .volumeAvailableCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
        ]
        guard let values = try? url.resourceValues(forKeys: keys) else { return 0 }
        let raw = Int64(values.volumeAvailableCapacity ?? 0)
        let important = values.volumeAvailableCapacityForImportantUsage ?? 0
        return max(0, important - raw)
    }
}
