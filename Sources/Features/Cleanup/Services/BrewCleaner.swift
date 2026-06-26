import Foundation

/// Homebrew 다운로드 캐시. HOMEBREW_CACHE 환경변수를 존중한다.
struct BrewCleaner: CleanerModule {
    let id = "brew"
    let category = ScanCategory.brew
    let displayName = "Homebrew 캐시"

    func scan(at root: String) async throws -> [ScanItem] {
        let cacheRoot = ProcessInfo.processInfo.environment["HOMEBREW_CACHE"]
            ?? root + "/Library/Caches/Homebrew"
        return ChildScanner.items(
            root: cacheRoot, category: .brew, defaultSelected: true, isSafe: true
        )
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
