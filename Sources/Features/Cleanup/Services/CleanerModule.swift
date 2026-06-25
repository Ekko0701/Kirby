import Foundation

/// 청소 가능한 한 범주를 표현하는 모듈.
///
/// 새 범주를 추가하려면 이 프로토콜을 구현한 타입 하나를 만들어 Coordinator의 modules에 넣으면
/// 된다. 뷰는 손대지 않아도 된다. (확장 seam)
protocol CleanerModule: Sendable {
    var id: String { get }
    var category: ScanCategory { get }
    var displayName: String { get }

    /// 홈 루트를 주입받아 삭제 후보를 스캔한다(테스트 위해 root 주입).
    func scan(at root: String) async throws -> [ScanItem]

    /// 선택된 항목을 영구 삭제하고 요약을 돌려준다.
    func clean(_ items: [ScanItem]) async throws -> CleanSummary
}
