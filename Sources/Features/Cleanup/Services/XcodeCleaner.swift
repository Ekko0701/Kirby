import Foundation

/// Xcode 정크. DerivedData·CoreSimulator 캐시·DeviceSupport(기본선택), Archives·CocoaPods(기본 해제).
/// CoreSimulator는 Caches만 — Devices(시뮬레이터 본체)는 절대 포함하지 않는다.
struct XcodeCleaner: CleanerModule {
    let id = "xcode"
    let category = ScanCategory.xcode
    let displayName = "Xcode 정크"

    struct JunkRoot: Sendable { let relativePath: String; let defaultSelected: Bool }

    static let roots: [JunkRoot] = [
        .init(relativePath: "Library/Developer/Xcode/DerivedData", defaultSelected: true),
        .init(relativePath: "Library/Developer/CoreSimulator/Caches", defaultSelected: true),
        .init(relativePath: "Library/Developer/Xcode/iOS DeviceSupport", defaultSelected: true),
        .init(relativePath: "Library/Developer/Xcode/watchOS DeviceSupport", defaultSelected: true),
        .init(relativePath: "Library/Developer/Xcode/tvOS DeviceSupport", defaultSelected: true),
        .init(relativePath: "Library/Developer/Xcode/Archives", defaultSelected: false),
        .init(relativePath: ".cocoapods", defaultSelected: false),
    ]

    func scan(at root: String) async throws -> [ScanItem] {
        var all: [ScanItem] = []
        for junk in Self.roots {
            if Task.isCancelled { break }
            all += ChildScanner.items(
                root: root + "/" + junk.relativePath,
                category: .xcode, defaultSelected: junk.defaultSelected, isSafe: true
            )
        }
        return all
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
