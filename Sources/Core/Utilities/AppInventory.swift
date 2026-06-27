import Foundation

/// 설치된 앱 개수(사이드바 배지용).
enum AppInventory {
    static func installedCount() -> Int {
        let dirs = ["/Applications", NSHomeDirectory() + "/Applications"]
        var count = 0
        for dir in dirs {
            let names = (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? []
            count += names.filter { $0.hasSuffix(".app") }.count
        }
        return count
    }
}
