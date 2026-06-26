import Foundation

/// AI 앱(Ollama, LM Studio)의 로그·캐시. 모델/대화 데이터는 건드리지 않는다.
struct AIAppsCleaner: CleanerModule {
    let id = "aiApps"
    let category = ScanCategory.aiApps
    let displayName = "AI 앱"

    func scan(at root: String) async throws -> [ScanItem] {
        var items: [ScanItem] = []
        let roots = [
            root + "/.ollama/logs",
            root + "/.cache/lm-studio",
            root + "/.lmstudio/.internal/logs",
        ]
        for path in roots {
            if Task.isCancelled { break }
            items += ChildScanner.items(
                root: path, category: .aiApps, defaultSelected: true, isSafe: true
            )
        }
        return items
    }

    func clean(_ items: [ScanItem]) async throws -> CleanSummary { HardDeleter.clean(items) }
}
