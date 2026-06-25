import Testing
import Foundation
@testable import Kirby

@Suite("SizeCalculator")
struct SizeCalculatorTests {
    @Test("중첩 파일 트리의 크기를 합산한다")
    func sumsTree() throws {
        let base = NSTemporaryDirectory() + "kirby-size-" + UUID().uuidString
        let sub = base + "/sub"
        try FileManager.default.createDirectory(atPath: sub, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: base) }
        let blob = Data(repeating: 0xAB, count: 10_000)
        try blob.write(to: URL(fileURLWithPath: base + "/a.bin"))
        try blob.write(to: URL(fileURLWithPath: sub + "/b.bin"))
        // 할당 크기는 블록 단위라 실제 데이터 합 이상이어야 한다.
        #expect(SizeCalculator.allocatedSize(atPath: base) >= 20_000)
    }

    @Test("빈 폴더는 0")
    func emptyFolder() throws {
        let base = NSTemporaryDirectory() + "kirby-empty-" + UUID().uuidString
        try FileManager.default.createDirectory(atPath: base, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: base) }
        #expect(SizeCalculator.allocatedSize(atPath: base) == 0)
    }
}
