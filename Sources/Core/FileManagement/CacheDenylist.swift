import Foundation

/// ~/Library/Caches 안에서 "캐시처럼 보이지만 지우면 안 되는" 폴더 이름.
/// iCloud 동기화 상태·신원/인증·프라이버시 등 재생성 불가/민감 데이터.
enum CacheDenylist {
    static let folderNames: Set<String> = [
        // iCloud / 동기화
        "CloudKit",
        "com.apple.bird",
        "com.apple.cloudd",
        "com.apple.cloudkit",
        "com.apple.cloudphotod",
        "com.apple.icloud.fmfd",
        "com.apple.itunescloudd",
        "FamilyCircle",
        // 신원 / 인증
        "com.apple.akd",
        "com.apple.containermanagerd",
        // Siri / 개인화 / 프라이버시
        "com.apple.assistant",
        "com.apple.assistantd",
        "com.apple.ap.adprivacyd",
        "com.apple.amsengagementd",
        "com.apple.Safari.SafeBrowsing",
    ]

    static func isDenied(folderName: String) -> Bool {
        folderNames.contains(folderName)
    }
}
