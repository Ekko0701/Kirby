import Foundation
import AppKit

/// Full Disk Access(FDA) 보유 여부를 추정한다.
///
/// macOS에는 FDA를 직접 묻는 공식 API가 없다. 그래서 FDA가 있어야만 읽히는 보호 경로를
/// 실제로 읽어보는 "프로브" 방식을 쓴다.
enum PermissionChecker {
    static func hasFullDiskAccess() -> Bool {
        let fm = FileManager.default
        let candidates = [
            NSHomeDirectory() + "/Library/Safari",
            NSHomeDirectory() + "/Library/Application Support/com.apple.TCC",
        ]
        for path in candidates where fm.fileExists(atPath: path) {
            return (try? fm.contentsOfDirectory(atPath: path)) != nil
        }
        // 보호 경로 후보가 없으면 캐시 접근으로 약하게 추정한다.
        return (try? fm.contentsOfDirectory(atPath: NSHomeDirectory() + "/Library/Caches")) != nil
    }

    @MainActor
    static func openSettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
