import Testing
@testable import Kirby

@Suite("CacheDenylist")
struct CacheDenylistTests {
    @Test("알려진 위험 폴더는 denied")
    func deniesKnown() {
        #expect(CacheDenylist.isDenied(folderName: "CloudKit"))
        #expect(CacheDenylist.isDenied(folderName: "com.apple.bird"))
    }

    @Test("일반 캐시 폴더는 허용")
    func allowsNormal() {
        #expect(!CacheDenylist.isDenied(folderName: "com.google.Chrome"))
        #expect(!CacheDenylist.isDenied(folderName: "Homebrew"))
    }
}
