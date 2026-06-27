import Foundation

/// 앱이 흔적을 남기는 ~/Library 하위 위치들.
enum LibraryLocations {
    static let roots = [
        "Library/Caches",
        "Library/Preferences",
        "Library/Application Support",
        "Library/Containers",
        "Library/Group Containers",
        "Library/Logs",
        "Library/Saved Application State",
        "Library/HTTPStorages",
        "Library/WebKit",
    ]
}
