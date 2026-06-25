import SwiftUI

/// DESIGN.md 팔레트를 SwiftUI로 옮긴 토큰.
///
/// SwiftUI 내장 `Color.primary`와 충돌하지 않도록 `Theme` 네임스페이스를 쓴다.
enum Theme {
    static let brandInk = Color(hex: 0x212121)      // 본문/링크 기본
    static let brandPrimary = Color(hex: 0x17171c)  // 주 CTA, 다크 카드
    static let cohereBlack = Color(hex: 0x000000)
    static let deepGreen = Color(hex: 0x003c33)      // 제품 다크 밴드
    static let darkNavy = Color(hex: 0x071829)
    static let canvas = Color(hex: 0xffffff)         // 기본 배경
    static let softStone = Color(hex: 0xeeece7)      // 따뜻한 중립 카드
    static let paleGreen = Color(hex: 0xedfce9)
    static let paleBlue = Color(hex: 0xf1f5ff)
    static let hairline = Color(hex: 0xd9d9dd)        // 기본 구분선
    static let borderLight = Color(hex: 0xe5e7eb)
    static let cardBorder = Color(hex: 0xf2f2f2)
    static let muted = Color(hex: 0x93939f)
    static let slate = Color(hex: 0x75758a)
    static let bodyMuted = Color(hex: 0x616161)
    static let actionBlue = Color(hex: 0x1863dc)     // 에디토리얼 링크
    static let focusBlue = Color(hex: 0x4c6ee6)
    static let coral = Color(hex: 0xff7759)          // 소량 액센트
    static let coralSoft = Color(hex: 0xffad9b)
    static let onDark = Color(hex: 0xffffff)
    static let errorRed = Color(hex: 0xb30000)
}

extension Color {
    /// 0xRRGGBB 정수로 sRGB 색을 만든다. 팔레트 값을 한 곳(Theme)에만 두기 위한 헬퍼.
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xff) / 255.0
        let green = Double((hex >> 8) & 0xff) / 255.0
        let blue = Double(hex & 0xff) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
