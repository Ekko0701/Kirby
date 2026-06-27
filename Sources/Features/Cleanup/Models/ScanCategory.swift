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

    /// 기본 선택/해제 규칙을 사용자에게 한 줄로 설명.
    var selectionNote: String {
        switch self {
        case .systemJunk: "최근 7일 이내 로그·시스템 캐시는 안전을 위해 기본 해제됩니다."
        case .userCache: "재생성되는 캐시라 기본 선택됩니다. 관련 앱은 종료 후 정리가 더 안전합니다."
        case .aiApps: "AI 앱 로그·캐시(모델·대화 제외)라 기본 선택됩니다."
        case .mail: "메일 첨부 사본이라 기본 선택됩니다(원본 메일은 유지)."
        case .trash: "휴지통 내용이라 기본 선택됩니다(영구 삭제)."
        case .xcode: "재생성되는 개발 캐시라 기본 선택됩니다(Archives·CocoaPods 제외)."
        case .brew: "재다운로드 가능한 캐시라 기본 선택됩니다."
        case .node: "재설치 가능한 패키지 캐시라 기본 선택됩니다."
        case .docker: "미사용 도커 캐시 — 안전을 위해 기본 해제됩니다. 선택 시 정리합니다."
        case .largeOld: "사용자 파일이라 기본 해제됩니다. 선택 항목은 휴지통으로 이동(복구 가능)."
        }
    }

    /// 스캔 결과가 비었을 때 보여줄 범주별 안내(왜 비었는지).
    var emptyNote: String {
        switch self {
        case .systemJunk: "정리할 로그·시스템 캐시가 없습니다."
        case .userCache: "정리할 캐시가 없습니다."
        case .aiApps: "Ollama·LM Studio가 설치되어 있지 않거나, 정리할 로그·캐시가 없습니다."
        case .mail: "정리할 메일 첨부가 없습니다."
        case .trash: "휴지통이 비어 있습니다."
        case .xcode: "정리할 Xcode 정크가 없습니다."
        case .brew: "Homebrew가 없거나 정리할 캐시가 없습니다."
        case .node: "npm·yarn·pnpm 캐시가 없습니다."
        case .docker: "Docker가 설치되어 있지 않거나 정리할 캐시가 없습니다."
        case .largeOld: "100MB 이상이거나 1년 넘은 파일이 없습니다."
        }
    }
}
