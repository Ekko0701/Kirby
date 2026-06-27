import Foundation

/// ~/Library 하위에서 "번들ID처럼 생긴" 항목 중 설치 앱/Apple 것이 아닌 고아를 찾는다.
enum OrphanScanner {
    static func scan(home: String = NSHomeDirectory(), installedBundleIDs: Set<String>) -> [AppFileItem] {
        var results: [AppFileItem] = []
        for rel in LibraryLocations.roots {
            let root = home + "/" + rel
            let names = (try? FileManager.default.contentsOfDirectory(atPath: root)) ?? []
            for name in names {
                guard let bundle = bundleIDLike(name) else { continue }
                let lower = bundle.lowercased()
                if lower.hasPrefix("com.apple.") { continue }
                if installedBundleIDs.contains(lower) { continue }
                let path = root + "/" + name
                results.append(AppFileItem(
                    path: path, displayName: rel + "/" + name,
                    sizeBytes: SizeCalculator.allocatedSize(atPath: path),
                    isSelected: false   // 고아는 사용자 검토 후 선택
                ))
            }
        }
        return results.sorted { $0.sizeBytes > $1.sizeBytes }
    }

    /// "com.foo.bar(.plist/.savedState/...)" → "com.foo.bar". 역도메인이 아니면 nil.
    static func bundleIDLike(_ name: String) -> String? {
        var base = name
        for ext in [".plist", ".savedState", ".binarycookies"] where base.hasSuffix(ext) {
            base = String(base.dropLast(ext.count))
        }
        let parts = base.split(separator: ".")
        guard parts.count >= 3, parts.allSatisfy({ !$0.isEmpty }) else { return nil }
        return base
    }
}
