import Testing
import Foundation
@testable import Kirby

@Suite("HardDeleter")
struct HardDeleterTests {
    @Test("선택 항목을 실제로 삭제하고 요약을 반환한다")
    func deletesItems() async throws {
        let root = NSTemporaryDirectory() + "kirby-del-" + UUID().uuidString
        let child = root + "/junk"
        try FileManager.default.createDirectory(atPath: child, withIntermediateDirectories: true)
        try Data(repeating: 1, count: 3_000).write(to: URL(fileURLWithPath: child + "/f.bin"))
        defer { try? FileManager.default.removeItem(atPath: root) }

        let item = ScanItem(path: child, displayName: "junk", category: .userCache,
                            sizeBytes: 3_000, isSafeToDelete: true, isSelectedByDefault: true)
        let manifest = DeleteManifest(directory: URL(fileURLWithPath: root + "/manifest"))
        let summary = HardDeleter.clean([item], manifest: manifest)

        #expect(summary.itemsCleaned == 1)
        #expect(summary.bytesFreed == 3_000)
        #expect(!FileManager.default.fileExists(atPath: child))
    }

    @Test("시스템 경로는 삭제하지 않고 에러로 남긴다")
    func refusesSystemPath() async throws {
        let item = ScanItem(path: "/System/Library/Caches/fake-xyz", displayName: "fake",
                            category: .userCache, sizeBytes: 100, isSafeToDelete: true,
                            isSelectedByDefault: true)
        let manifest = DeleteManifest(directory: URL(fileURLWithPath: NSTemporaryDirectory() + "kirby-m-" + UUID().uuidString))
        let summary = HardDeleter.clean([item], manifest: manifest)
        #expect(summary.itemsCleaned == 0)
        #expect(summary.errors.count == 1)
    }
}
