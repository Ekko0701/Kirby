import Foundation

/// 한 루트의 "직계 자식"들을 ScanItem 목록으로 만드는 공용 스캔 헬퍼.
///
/// 파일별이 아니라 자식 폴더/파일 단위로 집계해 수백만 항목 나열을 피한다(설계 보정).
enum ChildScanner {
    static func items(
        root: String,
        category: ScanCategory,
        defaultSelected: Bool,
        isSafe: Bool,
        exclude: Set<String> = [],
        olderThanDays: Int? = nil
    ) -> [ScanItem] {
        let fm = FileManager.default
        guard let names = try? fm.contentsOfDirectory(atPath: root) else { return [] }

        var result: [ScanItem] = []
        for name in names {
            if Task.isCancelled { break }
            if exclude.contains(name) { continue }
            let path = root + "/" + name
            let size = SizeCalculator.allocatedSize(atPath: path)
            if size == 0 { continue }   // 빈 항목은 보여주지 않는다

            var selected = defaultSelected
            if let days = olderThanDays {
                selected = isOlderThan(days: days, path: path)
            }
            result.append(ScanItem(
                path: path,
                displayName: name,
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
