import Foundation

/// 설치된 앱 조회(사이드바 배지 + 언인스톨러 + 고아 탐색 공용).
enum AppInventory {
    static let appDirs = ["/Applications", NSHomeDirectory() + "/Applications"]

    static func installedAppPaths() -> [String] {
        var paths: [String] = []
        for dir in appDirs {
            let names = (try? FileManager.default.contentsOfDirectory(atPath: dir)) ?? []
            paths += names.filter { $0.hasSuffix(".app") }.map { dir + "/" + $0 }
        }
        return paths
    }

    static func installedCount() -> Int { installedAppPaths().count }

    static func installedApps() -> [InstalledApp] {
        installedAppPaths().map { path in
            let name = String((path as NSString).lastPathComponent.dropLast(4))
            return InstalledApp(id: path, name: name, bundleID: bundleIdentifier(at: path), path: path)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func bundleIdentifier(at appPath: String) -> String? {
        NSDictionary(contentsOfFile: appPath + "/Contents/Info.plist")?["CFBundleIdentifier"] as? String
    }

    static func installedBundleIDs() -> Set<String> {
        Set(installedApps().compactMap { $0.bundleID?.lowercased() })
    }
}
