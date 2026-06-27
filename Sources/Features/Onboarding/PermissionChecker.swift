import Foundation
import AppKit

/// 전체 디스크 접근(FDA) 여부 판정 + 설정 열기.
enum PermissionChecker {
    /// FDA가 있어야만 읽히는 보호 경로(~/.Trash)로 판정한다.
    /// 휴지통/메일 같은 보호 항목 스캔 가능 여부와 직접 연결된다.
    static func hasFullDiskAccess() -> Bool {
        let trash = NSHomeDirectory() + "/.Trash"
        return (try? FileManager.default.contentsOfDirectory(atPath: trash)) != nil
    }

    @MainActor
    static func openSettings() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
