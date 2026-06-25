import Testing
@testable import Kirby

/// Step 1 스모크 테스트: 타깃이 빌드되고 테스트 러너가 도는지 확인.
@Suite("Smoke")
struct SmokeTests {
    @Test("Feature는 cleanup 케이스를 포함한다")
    func featureHasCleanup() {
        #expect(Feature.allCases.contains(.cleanup))
        #expect(Feature.cleanup.title == "Cleanup")
    }
}
