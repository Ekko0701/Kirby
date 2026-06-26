import Foundation

/// 청소 범주(PureMac 참고 10종). 새 범주 = case 추가 + 대응 CleanerModule.
enum ScanCategory: String, CaseIterable, Identifiable, Sendable {
    case systemJunk
    case userCache
    case aiApps
    case mail
    case trash
    case xcode
    case brew
    case node
    case docker
    case largeOld

    var id: String { rawValue }

    var title: String {
        switch self {
        case .systemJunk: "시스템 정크"
        case .userCache: "사용자 캐시"
        case .aiApps: "AI 앱"
        case .mail: "메일 첨부"
        case .trash: "휴지통"
        case .xcode: "Xcode 정크"
        case .brew: "Homebrew 캐시"
        case .node: "Node 캐시"
        case .docker: "Docker 캐시"
        case .largeOld: "대용량·오래된 파일"
        }
    }

    var systemImage: String {
        switch self {
        case .systemJunk: "gearshape"
        case .userCache: "shippingbox"
        case .aiApps: "brain"
        case .mail: "envelope"
        case .trash: "trash"
        case .xcode: "hammer"
        case .brew: "cup.and.saucer"
        case .node: "cube.box"
        case .docker: "cube.transparent"
        case .largeOld: "tray.full"
        }
    }
}
