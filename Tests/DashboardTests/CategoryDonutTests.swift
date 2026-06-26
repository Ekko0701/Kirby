import Testing
import SwiftUI
@testable import Kirby

@Suite("DonutMath")
struct DonutMathTests {
    private func seg(_ id: String, _ bytes: Int64) -> DonutSegment {
        DonutSegment(id: id, label: id, bytes: bytes, color: .clear)
    }

    @Test("호는 누적 비율로 0→1까지 이어진다")
    func cumulative() {
        let arcs = DonutMath.arcs(for: [seg("a", 50), seg("b", 50)])
        #expect(arcs.count == 2)
        #expect(abs(arcs[0].start - 0.0) < 1e-9)
        #expect(abs(arcs[0].end - 0.5) < 1e-9)
        #expect(abs(arcs[1].start - 0.5) < 1e-9)
        #expect(abs(arcs[1].end - 1.0) < 1e-9)
    }

    @Test("합이 0이면 빈 배열")
    func empty() {
        #expect(DonutMath.arcs(for: []).isEmpty)
        #expect(DonutMath.arcs(for: [seg("a", 0)]).isEmpty)
    }
}
