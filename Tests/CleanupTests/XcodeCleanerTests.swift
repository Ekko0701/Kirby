import Testing
import Foundation
@testable import Kirby

@Suite("XcodeCleaner")
struct XcodeCleanerTests {
    @Test("DerivedData는 기본 선택, Archives는 기본 해제")
    func scanDefaults() async throws {
        let home = NSTemporaryDirectory() + "kirby-xc-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        let derived = home + "/Library/Developer/Xcode/DerivedData/MyApp-abc"
        let archives = home + "/Library/Developer/Xcode/Archives/2026/x.xcarchive"
        for dir in [derived, archives] {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try Data(repeating: 1, count: 4_000).write(to: URL(fileURLWithPath: dir + "/f.bin"))
        }
        let items = try await XcodeCleaner().scan(at: home)
        #expect(items.first { $0.displayName == "MyApp-abc" }?.isSelected == true)
        #expect(items.first { $0.displayName == "2026" }?.isSelected == false)
    }
}
