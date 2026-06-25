import Foundation

/// 스캔으로 발견한 삭제 후보 하나. 보통 어떤 루트의 "직계 자식 폴더" 1개에 대응한다.
struct ScanItem: Identifiable, Sendable, Hashable {
    let id: String          // 경로를 그대로 고유 id로 사용
    let path: String
    let displayName: String
    let category: ScanCategory
    let sizeBytes: Int64
    let isSafeToDelete: Bool
    var isSelected: Bool

    init(
        path: String,
        displayName: String,
        category: ScanCategory,
        sizeBytes: Int64,
        isSafeToDelete: Bool,
        isSelectedByDefault: Bool
    ) {
        self.id = path
        self.path = path
        self.displayName = displayName
        self.category = category
        self.sizeBytes = sizeBytes
        self.isSafeToDelete = isSafeToDelete
        self.isSelected = isSelectedByDefault
    }
}
