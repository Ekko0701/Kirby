import Foundation

/// 개발자 정크 정리. 여러 알려진 루트를 한 범주로 묶어 스캔한다.
/// CoreSimulator는 Caches만 대상이며 Devices(시뮬레이터 본체)는 절대 포함하지 않는다.
struct DeveloperJunkCleaner: CleanerModule {
    let id = "developerJunk"
    let category = ScanCategory.developerJunk
    let displayName = "개발자 정크"

    struct JunkRoot: Sendable {
        let relativePath: String
        let defaultSelected: Bool
    }

    static let roots: [JunkRoot] = [
        .init(relativePath: "Library/Developer/Xcode/DerivedData", defaultSelected: true),
        .init(relativePath: "Library/Developer/CoreSimulator/Caches", defaultSelected: true),
        .init(relativePath: ".npm", defaultSelected: true),
        .init(relativePath: ".yarn/cache", defaultSelected: true),
        .init(relativePath: "Library/Caches/Homebrew", defaultSelected: true),
        .init(relativePath: ".cocoapods", defaultSelected: false),
        .init(relativePath: "Library/Developer/Xcode/Archives", defaultSelected: false),
    ]

    func scan(at root: String) async throws -> [ScanItem] {
        var all: [ScanItem] = []
        for junk in Self.roots {
            if Task.isCancelled { break }
            all += ChildScanner.items(
                root: root + "/" + junk.relativePath,
                category: .developerJunk,
                defaultSelected: junk.defaultSelected,
                isSafe: true
            )
        }
        return all
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary {
        HardDeleter.clean(items)
    }
}
