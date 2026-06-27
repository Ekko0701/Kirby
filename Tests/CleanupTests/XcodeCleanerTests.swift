import Testing
import Foundation
@testable import Kirby

@Suite("XcodeCleaner")
struct XcodeCleanerTests {
    private func makeDir(_ path: String, bytes: Int = 4_000) throws {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        try Data(repeating: 1, count: bytes).write(to: URL(fileURLWithPath: path + "/f.bin"))
    }

    @Test("DerivedData는 기본 선택, Archives는 기본 해제")
    func scanDefaults() async throws {
        let home = NSTemporaryDirectory() + "kirby-xc-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        try makeDir(home + "/Library/Developer/Xcode/DerivedData/MyApp-abc")
        try makeDir(home + "/Library/Developer/Xcode/Archives/2026/x.xcarchive")
        let items = try await XcodeCleaner().scan(at: home)
        #expect(items.first { $0.displayName == "MyApp-abc" }?.isSelected == true)
        #expect(items.first { $0.displayName == "2026" }?.isSelected == false)
    }

    @Test("iOS DeviceSupport도 기본 선택으로 스캔한다")
    func scanDeviceSupport() async throws {
        let home = NSTemporaryDirectory() + "kirby-xc2-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        try makeDir(home + "/Library/Developer/Xcode/iOS DeviceSupport/17.0 (21A000)")
        let items = try await XcodeCleaner().scan(at: home)
        #expect(items.first { $0.displayName == "17.0 (21A000)" }?.isSelected == true)
    }
}
