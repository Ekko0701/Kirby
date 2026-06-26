import Foundation

/// 앱이 기본으로 싣는 청소 모듈(표시 순서). 새 범주는 여기 추가하면 뷰 변경 없이 반영된다.
enum DefaultCleanerModules {
    static func all() -> [any CleanerModule] {
        [
            SystemJunkCleaner(),
            UserCacheCleaner(),
            AIAppsCleaner(),
            MailCleaner(),
            TrashCleaner(),
            XcodeCleaner(),
            BrewCleaner(),
            NodeCleaner(),
            DockerCleaner(),
            LargeOldCleaner(),
        ]
    }
}
