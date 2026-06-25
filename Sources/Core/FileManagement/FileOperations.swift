import Foundation

/// 검증을 통과한 경로만 실제로 삭제하는 얇은 래퍼.
struct FileOperations: Sendable {
    let validator: PathValidator

    /// 영구 삭제. 검증 실패 시 throw하고 절대 지우지 않는다.
    func remove(path: String) throws {
        try validator.validate(path)
        try FileManager.default.removeItem(atPath: path)
    }
}
