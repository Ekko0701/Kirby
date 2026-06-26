import Foundation

/// 디스크 사용량 스냅샷.
struct DiskUsage: Sendable, Equatable {
    let total: Int64
    let free: Int64

    var used: Int64 { max(0, total - free) }
    var usedFraction: Double { total > 0 ? min(1, Double(used) / Double(total)) : 0 }

    static let empty = DiskUsage(total: 0, free: 0)
}
