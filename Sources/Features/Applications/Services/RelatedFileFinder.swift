import Foundation

/// 앱의 번들ID/이름으로 ~/Library 하위 관련 파일(직계 자식)을 찾는다.
enum RelatedFileFinder {
    static func relatedItems(bundleID: String?, appName: String, home: String = NSHomeDirectory()) -> [AppFileItem] {
        let needles = [
            bundleID?.lowercased(),
            appName.lowercased().replacingOccurrences(of: " ", with: ""),
        ].compactMap { $0 }.filter { $0.count >= 3 }
        guard !needles.isEmpty else { return [] }

        var results: [AppFileItem] = []
        for rel in LibraryLocations.roots {
            let root = home + "/" + rel
            let names = (try? FileManager.default.contentsOfDirectory(atPath: root)) ?? []
            for name in names {
                let lower = name.lowercased().replacingOccurrences(of: " ", with: "")
                guard needles.contains(where: { lower.contains($0) }) else { continue }
                let path = root + "/" + name
                results.append(AppFileItem(
                    path: path, displayName: rel + "/" + name,
                    sizeBytes: SizeCalculator.allocatedSize(atPath: path)
                ))
            }
        }
        return results.sorted { $0.sizeBytes > $1.sizeBytes }
    }
}
