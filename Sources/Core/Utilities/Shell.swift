import Foundation

/// 외부 CLI 실행 헬퍼(비샌드박스 앱 전용). Docker 등 파일삭제가 아닌 정리에 사용.
enum Shell {
    /// 실행 파일을 찾는다(일반적인 설치 경로 우선).
    static func find(_ name: String) -> String? {
        let candidates = ["/opt/homebrew/bin/", "/usr/local/bin/", "/usr/bin/"].map { $0 + name }
        return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
    }

    /// 동기 실행. (output, exitCode) 반환, 실행 실패 시 nil.
    static func run(_ launchPath: String, _ arguments: [String]) -> (output: String, exitCode: Int32)? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do { try process.run() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (String(data: data, encoding: .utf8) ?? "", process.terminationStatus)
    }
}
