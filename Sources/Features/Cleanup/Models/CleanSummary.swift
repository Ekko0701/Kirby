import Foundation

/// 청소 결과 요약.
struct CleanSummary: Sendable {
    let itemsCleaned: Int
    let bytesFreed: Int64
    let errors: [CleanItemError]
    let timestamp: Date
}

/// 개별 항목 삭제 실패(사용 중/권한 등). 부분 실패 UX에 사용.
struct CleanItemError: Sendable, Identifiable, Hashable {
    let id: String          // path
    let path: String
    let message: String

    init(path: String, message: String) {
        self.id = path
        self.path = path
        self.message = message
    }
}
