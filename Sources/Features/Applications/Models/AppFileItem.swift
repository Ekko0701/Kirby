import Foundation

/// 앱 관련 파일 / 고아 파일 한 항목.
struct AppFileItem: Identifiable, Sendable, Hashable {
    let id: String
    let path: String
    let displayName: String
    let sizeBytes: Int64
    var isSelected: Bool

    init(path: String, displayName: String, sizeBytes: Int64, isSelected: Bool = true) {
        self.id = path
        self.path = path
        self.displayName = displayName
        self.sizeBytes = sizeBytes
        self.isSelected = isSelected
    }
}

/// 설치된 앱 한 개.
struct InstalledApp: Identifiable, Sendable, Hashable {
    let id: String          // .app 경로
    let name: String
    let bundleID: String?
    let path: String
}
