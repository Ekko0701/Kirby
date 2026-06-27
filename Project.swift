import ProjectDescription

// Kirby — macOS Cleanup 유틸리티. 비샌드박스 + Full Disk Access.
// `tuist generate`로 .xcodeproj 생성. 자세한 배경은 PLAN.md 참고.
let project = Project(
    name: "Kirby",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "en"
    ),
    targets: [
        .target(
            name: "Kirby",
            destinations: .macOS,
            product: .app,
            bundleId: "com.kimdongjoo.Kirby",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Kirby",
                "LSMinimumSystemVersion": "26.0",
                "LSApplicationCategoryType": "public.app-category.utilities",
                "ITSAppUsesNonExemptEncryption": false,
                "NSHumanReadableCopyright": "Copyright © 2026 kimdongjoo. All rights reserved.",
                "CFBundleShortVersionString": "0.5.0",
                "CFBundleVersion": "5"
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [],
            settings: .settings(base: [
                "MARKETING_VERSION": "0.5.0",
                "CURRENT_PROJECT_VERSION": "5",
                "SWIFT_VERSION": "6.0",
                "CODE_SIGN_IDENTITY": "-",
                "CODE_SIGN_STYLE": "Manual",
                "ENABLE_HARDENED_RUNTIME": "YES",
                "DEAD_CODE_STRIPPING": "YES",
                "SWIFT_STRICT_CONCURRENCY": "complete",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon"
            ])
        ),
        .target(
            name: "KirbyTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.kimdongjoo.KirbyTests",
            deploymentTargets: .macOS("26.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Kirby")],
            settings: .settings(base: [
                "SWIFT_VERSION": "6.0",
                "SWIFT_STRICT_CONCURRENCY": "complete"
            ])
        )
    ]
)
