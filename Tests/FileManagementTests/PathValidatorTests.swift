import Testing
import Foundation
@testable import Kirby

@Suite("PathValidator")
struct PathValidatorTests {
    private func makeTempRoot() throws -> String {
        let base = NSTemporaryDirectory() + "kirby-pv-" + UUID().uuidString
        try FileManager.default.createDirectory(atPath: base, withIntermediateDirectories: true)
        return base
    }

    @Test("화이트리스트 루트 안의 자식 폴더는 허용한다")
    func allowsChild() throws {
        let root = try makeTempRoot()
        defer { try? FileManager.default.removeItem(atPath: root) }
        let child = root + "/com.apple.Safari"
        try FileManager.default.createDirectory(atPath: child, withIntermediateDirectories: true)
        let validator = PathValidator(allowedRoots: [root])
        try validator.validate(child)   // throw하지 않아야 한다
    }

    @Test("루트 밖 경로는 거부한다")
    func rejectsOutside() throws {
        let root = try makeTempRoot()
        defer { try? FileManager.default.removeItem(atPath: root) }
        let validator = PathValidator(allowedRoots: [root])
        #expect(throws: PathValidator.Rejection.outsideAllowedRoots) {
            try validator.validate(NSTemporaryDirectory() + "kirby-elsewhere-xyz")
        }
    }

    @Test("루트 자신은 거부한다(내용만 삭제)")
    func rejectsRootItself() throws {
        let root = try makeTempRoot()
        defer { try? FileManager.default.removeItem(atPath: root) }
        let validator = PathValidator(allowedRoots: [root])
        #expect(throws: PathValidator.Rejection.isRootItself) {
            try validator.validate(root)
        }
    }

    @Test("시스템 경로는 거부한다")
    func rejectsSystemPath() {
        let validator = PathValidator(allowedRoots: ["/System/Library/Caches"])
        #expect(throws: PathValidator.Rejection.deniedSystemPath) {
            try validator.validate("/System/Library/Caches/whatever")
        }
    }
}
