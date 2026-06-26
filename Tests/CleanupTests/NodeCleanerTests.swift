import Testing
import Foundation
@testable import Kirby

@Suite("NodeCleaner")
struct NodeCleanerTests {
    @Test("npm과 pnpm store 자식을 스캔한다")
    func scanIncludesPnpm() async throws {
        let home = NSTemporaryDirectory() + "kirby-node-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        for path in [home + "/.npm/registry/f.bin", home + "/Library/pnpm/store/v3/f.bin"] {
            let dir = (path as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try Data(repeating: 1, count: 3_000).write(to: URL(fileURLWithPath: path))
        }
        let items = try await NodeCleaner().scan(at: home)
        #expect(items.contains { $0.displayName == "registry" })
        #expect(items.contains { $0.displayName == "v3" })
    }
}
