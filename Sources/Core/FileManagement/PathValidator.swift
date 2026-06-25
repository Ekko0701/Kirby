import Foundation

/// 삭제 직전 경로 안전성 검증기. 하드 삭제(removeItem) 전에 반드시 통과해야 한다.
///
/// 안전 모델의 핵심: "화이트리스트 루트 안에 있는, 루트 자신이 아닌, 밖을 가리키지 않는,
/// 시스템 경로가 아닌" 경로만 허용한다.
struct PathValidator: Sendable {
    let allowedRoots: [String]

    /// 절대 건드리면 안 되는 시스템 경로 접두사.
    static let deniedPrefixes: [String] = [
        "/System", "/usr", "/bin", "/sbin", "/Library/Apple",
    ]

    /// 홈 기준 거부 하위 경로(실제 홈에 대한 추가 가드).
    static let deniedHomeSubpaths: [String] = [
        "Library/Preferences",
        "Library/Application Support",
        "Library/Keychains",
        "Library/Developer/CoreSimulator/Devices",
    ]

    init(allowedRoots: [String]) {
        self.allowedRoots = allowedRoots.map { ($0 as NSString).standardizingPath }
    }

    enum Rejection: Error, Equatable {
        case outsideAllowedRoots
        case deniedSystemPath
        case symlinkEscapesRoot
        case isRootItself
    }

    func validate(_ path: String) throws {
        let std = (path as NSString).standardizingPath

        // 1) 시스템 경로 거부
        for prefix in Self.deniedPrefixes where std == prefix || std.hasPrefix(prefix + "/") {
            throw Rejection.deniedSystemPath
        }
        let home = NSHomeDirectory()
        for sub in Self.deniedHomeSubpaths {
            let full = (home as NSString).appendingPathComponent(sub)
            if std == full || std.hasPrefix(full + "/") {
                throw Rejection.deniedSystemPath
            }
        }

        // 2) 화이트리스트 루트 내부인지
        guard let containing = allowedRoots.first(where: { std == $0 || std.hasPrefix($0 + "/") }) else {
            throw Rejection.outsideAllowedRoots
        }

        // 3) 루트 자신은 삭제 금지(내용만)
        if std == containing {
            throw Rejection.isRootItself
        }

        // 4) 심볼릭 링크가 루트 밖을 가리키면 거부
        if let target = try? FileManager.default.destinationOfSymbolicLink(atPath: std) {
            let base = (std as NSString).deletingLastPathComponent
            let resolved = absolutize(target, relativeTo: base)
            let inside = allowedRoots.contains { resolved == $0 || resolved.hasPrefix($0 + "/") }
            if !inside { throw Rejection.symlinkEscapesRoot }
        }
    }

    private func absolutize(_ target: String, relativeTo base: String) -> String {
        if target.hasPrefix("/") { return (target as NSString).standardizingPath }
        return ((base as NSString).appendingPathComponent(target) as NSString).standardizingPath
    }
}
