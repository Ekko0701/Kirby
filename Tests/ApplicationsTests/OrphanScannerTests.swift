import Testing
import Foundation
@testable import Kirby

@Suite("OrphanScanner")
struct OrphanScannerTests {
    private func touch(_ path: String) throws {
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try Data([1]).write(to: URL(fileURLWithPath: path))
    }

    @Test("설치 앱/Apple/비-번들 항목을 제외하고 고아만 찾는다")
    func findsOrphans() throws {
        let home = NSTemporaryDirectory() + "kirby-orph-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        try touch(home + "/Library/Caches/com.orphan.app/a.bin")
        try touch(home + "/Library/Caches/com.apple.thing/b.bin")
        try touch(home + "/Library/Caches/com.installed.app/c.bin")
        try touch(home + "/Library/Caches/randomfolder/d.bin")

        let orphans = OrphanScanner.scan(home: home, installedBundleIDs: ["com.installed.app"])
        let names = orphans.map(\.displayName)
        #expect(names.contains("Library/Caches/com.orphan.app"))
        #expect(!names.contains { $0.contains("com.apple.thing") })
        #expect(!names.contains { $0.contains("com.installed.app") })
        #expect(!names.contains { $0.contains("randomfolder") })
    }

    @Test("번들ID 형태 판별")
    func bundleIDLike() {
        #expect(OrphanScanner.bundleIDLike("com.foo.bar") == "com.foo.bar")
        #expect(OrphanScanner.bundleIDLike("com.foo.bar.plist") == "com.foo.bar")
        #expect(OrphanScanner.bundleIDLike("Caches") == nil)
        #expect(OrphanScanner.bundleIDLike("two.parts") == nil)
    }
}
