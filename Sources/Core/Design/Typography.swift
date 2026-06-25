import SwiftUI

/// DESIGN.md 타이포 스케일을 SF Pro / SF Mono 폴백으로 매핑.
///
/// 독점 폰트(CohereText/Unica77/CohereMono)는 번들하지 않으므로 시스템 폰트로 대체한다.
enum VFont {
    static let heroDisplay96 = Font.system(size: 96, weight: .regular)
    static let productDisplay72 = Font.system(size: 72, weight: .regular)
    static let sectionDisplay60 = Font.system(size: 60, weight: .regular)
    static let sectionHeading48 = Font.system(size: 48, weight: .regular)
    static let cardHeading32 = Font.system(size: 32, weight: .regular)
    static let featureHeading24 = Font.system(size: 24, weight: .regular)
    static let bodyLarge18 = Font.system(size: 18, weight: .regular)
    static let body16 = Font.system(size: 16, weight: .regular)
    static let button14 = Font.system(size: 14, weight: .medium)
    static let caption14 = Font.system(size: 14, weight: .regular)
    static let monoLabel14 = Font.system(size: 14, weight: .regular).monospaced()
    static let micro12 = Font.system(size: 12, weight: .regular)
}
