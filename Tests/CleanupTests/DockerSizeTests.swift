import Testing
import Foundation
@testable import Kirby

@Suite("DockerCleaner.parseSize")
struct DockerSizeTests {
    @Test("단위별 크기 파싱")
    func parse() {
        #expect(DockerCleaner.parseSize("1.5GB (50%)") == Int64(1.5 * pow(1024, 3)))
        #expect(DockerCleaner.parseSize("512MB") == Int64(512 * 1024 * 1024))
        #expect(DockerCleaner.parseSize("0B (0%)") == 0)
        #expect(DockerCleaner.parseSize("garbage") == 0)
    }
}
