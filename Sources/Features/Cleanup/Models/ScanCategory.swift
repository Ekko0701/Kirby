import Foundation

/// 청소 범주. 새 범주를 추가하면 여기 case를 더하고 대응 CleanerModule을 만든다.
enum ScanCategory: String, CaseIterable, Identifiable, Sendable {
    case cache
    case logs
    case trash
    case developerJunk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cache: "사용자 캐시"
        case .logs: "로그"
        case .trash: "휴지통"
        case .developerJunk: "개발자 정크"
        }
    }

    var systemImage: String {
        switch self {
        case .cache: "shippingbox"
        case .logs: "doc.text"
        case .trash: "trash"
        case .developerJunk: "hammer"
        }
    }
}
