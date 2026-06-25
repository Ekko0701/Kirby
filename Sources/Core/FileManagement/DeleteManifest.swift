import Foundation

/// 삭제 직전 어떤 경로를 지웠는지 로그로 남긴다(하드 삭제의 안전 보완).
/// 로깅 실패가 삭제를 막지는 않는다(보조 기능).
struct DeleteManifest: Sendable {
    let directory: URL

    init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let library = FileManager.default
                .urls(for: .libraryDirectory, in: .userDomainMask).first
            self.directory = (library ?? URL(fileURLWithPath: NSTemporaryDirectory()))
                .appendingPathComponent("Logs/Kirby", isDirectory: true)
        }
    }

    func record(paths: [String], at date: Date) {
        guard !paths.isEmpty else { return }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let stamp = ISO8601DateFormatter().string(from: date)
            .replacingOccurrences(of: ":", with: "-")
        let file = directory.appendingPathComponent("clean-\(stamp).log")
        let body = paths.joined(separator: "\n") + "\n"
        try? body.write(to: file, atomically: true, encoding: .utf8)
    }
}
