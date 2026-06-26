import Foundation

/// 사이드바 섹션(메뉴 그룹).
enum FeatureSection: String, CaseIterable, Identifiable, Sendable {
    case cleanup = "정리"
    case tools = "도구"
    var id: String { rawValue }
}

/// 앱 최상위 기능 축. 새 기능은 케이스를 더하면 사이드바/라우팅이 확장된다.
enum Feature: String, CaseIterable, Identifiable, Sendable {
    case dashboard
    case cleanup
    case uninstaller
    case orphanFinder

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .cleanup: "Cleanup"
        case .uninstaller: "Uninstaller"
        case .orphanFinder: "Orphan Finder"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "gauge.medium"
        case .cleanup: "sparkles"
        case .uninstaller: "xmark.bin"
        case .orphanFinder: "magnifyingglass"
        }
    }

    var section: FeatureSection {
        switch self {
        case .dashboard, .cleanup: .cleanup
        case .uninstaller, .orphanFinder: .tools
        }
    }

    static func features(in section: FeatureSection) -> [Feature] {
        allCases.filter { $0.section == section }
    }
}
