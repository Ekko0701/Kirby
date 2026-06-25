import Foundation

/// 청소 과정의 도메인 에러.
enum CleanError: Error, Sendable, Equatable {
    case pathRejected(String)
    case notPermitted(String)
    case underlying(String)
}
