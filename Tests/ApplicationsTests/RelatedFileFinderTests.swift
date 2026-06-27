import Testing
import Foundation
@testable import Kirby

@Suite("RelatedFileFinder")
struct RelatedFileFinderTests {
    private func touch(_ path: String) throws {
        let dir = (path as NSString).deletingLastPathComponent
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        try Data([1, 2, 3]).write(to: URL(fileURLWithPath: path))
    }

    @Test("번들ID와 앱 이름으로 관련 파일을 찾는다")
    func findsRelated() throws {
        let home = NSTemporaryDirectory() + "kirby-rel-" + UUID().uuidString
        defer { try? FileManager.default.removeItem(atPath: home) }
        try touch(home + "/Library/Caches/com.foo.bar/data.bin")
        try touch(home + "/Library/Preferences/com.foo.bar.plist")
        try touch(home + "/Library/Application Support/Foo/x.bin")
        try touch(home + "/Library/Caches/com.other.app/y.bin")

        let items = RelatedFileFinder.relatedItems(bundleID: "com.foo.bar", appName: "Foo", home: home)
        let names = items.map(\.displayName)
        #expect(names.contains("Library/Caches/com.foo.bar"))
        #expect(names.contains("Library/Preferences/com.foo.bar.plist"))
        #expect(names.contains("Library/Application Support/Foo"))
        #expect(!names.contains("Library/Caches/com.other.app"))
    }
}
