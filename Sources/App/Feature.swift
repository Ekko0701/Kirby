import Foundation

/// 앱 최상위 기능 축.
///
/// MVP는 `.cleanup` 하나뿐이지만, 이후 언인스톨러 등은 여기에 case를 더하면
/// 사이드바와 라우팅이 자동으로 확장된다(뷰 분기만 추가).
enum Feature: String, CaseIterable, Identifiable, Sendable {
    case cleanup

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cleanup: "Cleanup"
        }
    }

    var systemImage: String {
        switch self {
        case .cleanup: "sparkles"
        }
    }
}
