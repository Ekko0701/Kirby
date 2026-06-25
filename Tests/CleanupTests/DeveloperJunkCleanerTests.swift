import Testing
import Foundation
@testable import Kirby

@Suite("DeveloperJunkCleaner")
struct DeveloperJunkCleanerTests {
    @Test("DerivedData 자식을 기본 선택으로, Archives는 기본 해제로 스캔한다")
    func scanDefaults() async throws {
        let home = NSTemporaryDirectory() + "kirby-dev-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        let derived = home + "/Library/Developer/Xcode/DerivedData/MyApp-abc"
        let archives = home + "/Library/Developer/Xcode/Archives/2026/x.xcarchive"
        for dir in [derived, archives] {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
            try Data(repeating: 1, count: 4_000).write(to: URL(fileURLWithPath: dir + "/f.bin"))
        }
        let items = try await DeveloperJunkCleaner().scan(at: home)
        let derivedItem = items.first { $0.displayName == "MyApp-abc" }
        let archiveItem = items.first { $0.displayName == "2026" }
        #expect(derivedItem?.isSelected == true)
        #expect(archiveItem?.isSelected == false)
    }
}
