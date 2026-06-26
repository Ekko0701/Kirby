import Testing
@testable import Kirby

@Suite("DiskUsage")
struct DiskUsageTests {
    @Test("used = total - free, fraction 정확")
    func used() {
        let usage = DiskUsage(total: 1000, free: 300)
        #expect(usage.used == 700)
        #expect(abs(usage.usedFraction - 0.7) < 0.0001)
    }

    @Test("total 0이면 fraction 0")
    func zeroTotal() {
        #expect(DiskUsage(total: 0, free: 0).usedFraction == 0)
    }

    @Test("free가 total보다 커도 used는 0 이상")
    func clampUsed() {
        #expect(DiskUsage(total: 100, free: 200).used == 0)
    }
}
