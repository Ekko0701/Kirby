import Foundation

/// ~/Library/Caches 안에서 "캐시처럼 보이지만 지우면 안 되는" 폴더 이름.
/// 동기화 상태·재생성 불가 데이터 등. 결정 2(소규모 denylist) 참고.
enum CacheDenylist {
    static let folderNames: Set<String> = [
        "CloudKit",
        "com.apple.bird",
        "com.apple.cloudd",
        "com.apple.cloudkit",
        "com.apple.cloudphotod",
        "FamilyCircle",
        "com.apple.Safari.SafeBrowsing",
        "com.apple.containermanagerd",
    ]

    static func isDenied(folderName: String) -> Bool {
        folderNames.contains(folderName)
    }
}
