import Foundation
import AppKit

/// 디스크 접근 가능 여부를 추정한다.
///
/// 청소의 핵심 대상인 `~/Library/Caches`를 실제로 읽을 수 있으면 동작 가능으로 본다.
/// (완전한 보호 캐시까지 읽으려면 전체 디스크 접근 권한이 더 도움이 되지만, 기본 대상은
/// FDA 없이도 읽히므로 사용을 막지 않는다.)
enum PermissionChecker {
    static func hasFullDiskAccess() -> Bool {
        let target = NSHomeDirectory() + "/Library/Caches"
        return (try? FileManager.default.contentsOfDirectory(atPath: target)) != nil
    }

    @MainActor
    static func openSettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
