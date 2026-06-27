import Foundation

/// 한 루트의 "직계 자식"들을 ScanItem 목록으로 만드는 공용 스캔 헬퍼.
enum ChildScanner {
    static func items(
        root: String,
        category: ScanCategory,
        defaultSelected: Bool,
        isSafe: Bool,
        exclude: Set<String> = [],
        olderThanDays: Int? = nil,
        displayPrefix: String = ""
    ) -> [ScanItem] {
        let fm = FileManager.default
        guard let names = try? fm.contentsOfDirectory(atPath: root) else { return [] }

        var result: [ScanItem] = []
        for name in names {
            if Task.isCancelled { break }
            if exclude.contains(name) { continue }
            let path = root + "/" + name
            let size = SizeCalculator.allocatedSize(atPath: path)
            if size == 0 { continue }

            var selected = defaultSelected
            if let days = olderThanDays {
                selected = isOlderThan(days: days, path: path)
            }
            let display = displayPrefix.isEmpty ? name : displayPrefix + " · " + name
            result.append(ScanItem(
                path: path,
                displayName: display,
                category: category,
                sizeBytes: size,
                isSafeToDelete: isSafe,
                isSelectedByDefault: selected
            ))
        }
        return result
    }

    static func isOlderThan(days: Int, path: String) -> Bool {
        let attrs = try? FileManager.default.attributesOfItem(atPath: path)
        guard let modified = attrs?[.modificationDate] as? Date else { return false }
        return Date().timeIntervalSince(modified) > Double(days) * 86_400
    }
}
