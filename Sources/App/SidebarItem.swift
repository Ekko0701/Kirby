import Foundation

/// 좌측 인스펙터 섹션.
enum SidebarSection: String, CaseIterable, Identifiable {
    case overview = "OVERVIEW"
    case applications = "APPLICATIONS"
    case cleanup = "CLEANUP"

    var id: String { rawValue }

    var items: [SidebarItem] {
        switch self {
        case .overview:
            [.dashboard]
        case .applications:
            [.installedApps, .orphanedFiles]
        case .cleanup:
            [
                .category(.systemJunk), .category(.userCache), .category(.aiApps),
                .category(.mail), .category(.trash), .category(.largeOld),
                .purgeable,
                .category(.xcode), .category(.brew), .category(.node), .category(.docker),
            ]
        }
    }
}

/// 좌측 인스펙터의 개별 항목.
enum SidebarItem: Hashable, Identifiable {
    case dashboard
    case installedApps
    case orphanedFiles
    case category(ScanCategory)
    case purgeable

    var id: String {
        switch self {
        case .dashboard: "dashboard"
        case .installedApps: "installedApps"
        case .orphanedFiles: "orphanedFiles"
        case .category(let c): "cat." + c.rawValue
        case .purgeable: "purgeable"
        }
    }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .installedApps: "Installed Apps"
        case .orphanedFiles: "Orphaned Files"
        case .category(let c): c.title
        case .purgeable: "Purgeable Space"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "gauge.medium"
        case .installedApps: "square.grid.2x2"
        case .orphanedFiles: "doc.questionmark"
        case .category(let c): c.systemImage
        case .purgeable: "arrow.3.trianglepath"
        }
    }
}
