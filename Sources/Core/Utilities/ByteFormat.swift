import Foundation

/// 바이트 → 사람이 읽는 문자열. ByteCountFormatter 래핑.
enum ByteFormat {
    static func string(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: max(0, bytes))
    }
}
