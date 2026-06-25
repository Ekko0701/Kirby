import Foundation

/// 스캔/청소 플로우의 상태 머신.
enum ScanState: Sendable, Equatable {
    case idle
    case scanning(progress: Double)
    case scanned
    case cleaning(progress: Double)
    case completed
    case failed(String)
}
