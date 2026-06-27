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
        case .systemJunk: "System Junk"
        case .userCache: "User Cache"
        case .aiApps: "AI Apps"
        case .mail: "Mail Files"
        case .trash: "Trash Bins"
        case .xcode: "Xcode Junk"
        case .brew: "Brew Cache"
        case .node: "Node Cache"
        case .docker: "Docker Cache"
        case .largeOld: "Large & Old Files"
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
        case .largeOld: "doc.text"
        }
    }
}
