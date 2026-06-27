import Foundation

/// 검증된 경로를 휴지통으로 이동(복구 가능). 언인스톨러/고아 정리에 사용.
enum TrashRemover {
    static let deniedPrefixes = ["/System", "/usr", "/bin", "/sbin", "/Library/Apple"]

    static func trash(_ paths: [String]) -> CleanSummary {
        let fm = FileManager.default
        let home = NSHomeDirectory()
        var cleaned = 0
        var freed: Int64 = 0
        var errors: [CleanItemError] = []

        for path in paths {
            let std = (path as NSString).standardizingPath
            if deniedPrefixes.contains(where: { std == $0 || std.hasPrefix($0 + "/") }) {
                errors.append(CleanItemError(path: std, message: "시스템 경로 — 건너뜀")); continue
            }
            let allowed = std.hasPrefix(home + "/") || std.hasPrefix("/Applications/")
            guard allowed else {
                errors.append(CleanItemError(path: std, message: "허용되지 않은 경로 — 건너뜀")); continue
            }
            let size = SizeCalculator.allocatedSize(atPath: std)
            do {
                try fm.trashItem(at: URL(fileURLWithPath: std), resultingItemURL: nil)
                cleaned += 1
                freed += size
            } catch {
                errors.append(CleanItemError(path: std, message: String(describing: error)))
            }
        }
        return CleanSummary(itemsCleaned: cleaned, bytesFreed: freed, errors: errors, timestamp: Date())
    }
}
