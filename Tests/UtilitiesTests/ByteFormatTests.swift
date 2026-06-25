import Testing
@testable import Kirby

@Suite("ByteFormat")
struct ByteFormatTests {
    @Test("음수는 빈 문자열이 아니다(0 처리)")
    func negativeIsSafe() {
        #expect(!ByteFormat.string(-100).isEmpty)
    }

    @Test("메가바이트 단위를 표시한다")
    func megabytes() {
        #expect(ByteFormat.string(5_000_000).contains("MB"))
    }
}
