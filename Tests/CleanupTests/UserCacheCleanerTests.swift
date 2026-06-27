import Testing
import Foundation
@testable import Kirby

@Suite("UserCacheCleaner")
struct UserCacheCleanerTests {
    private func writeFile(_ path: String, bytes: Int = 5_000) throws {
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try Data(repeating: 1, count: bytes).write(to: URL(fileURLWithPath: path))
    }

    @Test("자식 캐시 폴더를 스캔하고 denylist 항목은 제외한다")
    func scanExcludesDenylist() async throws {
        let home = NSTemporaryDirectory() + "kirby-uc-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        let caches = home + "/Library/Caches"
        try writeFile(caches + "/com.google.Chrome/data.bin")
        try writeFile(caches + "/CloudKit/db.bin")
        let items = try await UserCacheCleaner().scan(at: home)
        #expect(items.contains { $0.displayName == "com.google.Chrome" })
        #expect(!items.contains { $0.displayName == "CloudKit" })
    }

    @Test("샌드박스 컨테이너 캐시도 스캔한다")
    func scanContainerCaches() async throws {
        let home = NSTemporaryDirectory() + "kirby-uc2-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        try writeFile(home + "/Library/Containers/com.foo.bar/Data/Library/Caches/blob/x.bin")
        let items = try await UserCacheCleaner().scan(at: home)
        #expect(items.contains { $0.displayName.contains("com.foo.bar") })
    }
}
