import Testing
@testable import Kirby

/// 스모크 테스트: 사이드바 구조가 기대대로 구성되는지 확인.
@Suite("Smoke")
struct SmokeTests {
    @Test("CLEANUP 섹션은 청소 범주와 Purgeable Space를 포함한다")
    func sidebarCleanupSection() {
        let items = SidebarSection.cleanup.items
        #expect(items.contains(.category(.systemJunk)))
        #expect(items.contains(.category(.docker)))
        #expect(items.contains(.purgeable))
    }

    @Test("OVERVIEW/APPLICATIONS 섹션 구성")
    func sidebarOtherSections() {
        #expect(SidebarSection.overview.items == [.dashboard])
        #expect(SidebarSection.applications.items.contains(.installedApps))
        #expect(SidebarSection.applications.items.contains(.orphanedFiles))
    }
}
