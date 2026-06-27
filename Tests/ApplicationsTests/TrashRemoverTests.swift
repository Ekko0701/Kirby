import Testing
import Foundation
@testable import Kirby

@Suite("TrashRemover")
struct TrashRemoverTests {
    @Test("시스템 경로는 거부한다")
    func rejectsSystemPath() {
        let summary = TrashRemover.trash(["/System/Library/Caches/fake-xyz"])
        #expect(summary.itemsCleaned == 0)
        #expect(summary.errors.count == 1)
    }

    @Test("홈 밖(임시 경로)은 거부한다")
    func rejectsOutsideHome() {
        let summary = TrashRemover.trash([NSTemporaryDirectory() + "kirby-not-home-xyz"])
        #expect(summary.itemsCleaned == 0)
    }

    @Test("홈 하위 파일은 휴지통으로 이동한다")
    func trashesHomeFile() throws {
        let path = NSHomeDirectory() + "/.kirby-trash-test-" + UUID().uuidString
        try Data([1, 2, 3]).write(to: URL(fileURLWithPath: path))
        let summary = TrashRemover.trash([path])
        #expect(summary.itemsCleaned == 1)
        #expect(!FileManager.default.fileExists(atPath: path))
    }
}
