import Testing
import Foundation
@testable import Kirby

@Suite("CachesCleaner")
struct CachesCleanerTests {
    private func writeFile(_ path: String, bytes: Int = 5_000) throws {
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try Data(repeating: 1, count: bytes).write(to: URL(fileURLWithPath: path))
    }

    @Test("자식 캐시 폴더를 스캔하고 denylist 항목은 제외한다")
    func scanExcludesDenylist() async throws {
        let home = NSTemporaryDirectory() + "kirby-home-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        let caches = home + "/Library/Caches"
        try writeFile(caches + "/com.google.Chrome/data.bin")
        try writeFile(caches + "/CloudKit/db.bin")     // denylist 대상

        let items = try await CachesCleaner().scan(at: home)
        #expect(items.contains { $0.displayName == "com.google.Chrome" })
        #expect(!items.contains { $0.displayName == "CloudKit" })
    }
}
