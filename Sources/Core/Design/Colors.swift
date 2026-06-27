import SwiftUI

/// 오로라(바이올렛·블루·틸) 다크 테마 토큰. 기존 토큰명을 유지하되 다크값으로 리포인트.
enum Theme {
    // 오로라 액센트
    static let violet = Color(hex: 0x7C5CFF)
    static let indigo = Color(hex: 0x5B7CFF)
    static let blue = Color(hex: 0x4C7DFF)
    static let teal = Color(hex: 0x2DD4BF)

    // 다크 베이스
    static let bg0 = Color(hex: 0x0B0B14)
    static let bg1 = Color(hex: 0x14122A)

    // 시맨틱(다크 리포인트)
    static let canvas = Color(hex: 0x0E0E1A)
    static let cohereBlack = Color(hex: 0x05050A)
    static let brandInk = Color(hex: 0xF3F3FA)          // 기본 텍스트(밝음)
    static let brandPrimary = violet                     // 주 CTA 베이스
    static let deepGreen = teal                          // 강조(밴드/링/체크)
    static let darkNavy = Color(hex: 0x1B2A4A)
    static let softStone = Color(white: 1, opacity: 0.06) // 글래스 표면
    static let hairline = Color(white: 1, opacity: 0.12)
    static let borderLight = Color(white: 1, opacity: 0.08)
    static let cardBorder = Color(white: 1, opacity: 0.10)
    static let muted = Color(hex: 0x7C7C97)
    static let slate = Color(hex: 0x9A9AB6)
    static let bodyMuted = Color(hex: 0xAEAECB)
    static let actionBlue = Color(hex: 0x7AA2FF)
    static let focusBlue = Color(hex: 0x7AA2FF)
    static let coral = Color(hex: 0xFF7E6B)
    static let coralSoft = Color(hex: 0xFFAD9B)
    static let onDark = Color.white
    static let errorRed = Color(hex: 0xFF6B6B)

    // 그라데이션
    static let aurora = LinearGradient(
        colors: [violet, blue, teal],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    static let ringGradient = AngularGradient(
        gradient: Gradient(colors: [violet, blue, teal, violet]),
        center: .center)
    static let cardSurface = LinearGradient(
        colors: [Color(white: 1, opacity: 0.10), Color(white: 1, opacity: 0.03)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    static let bandGradient = LinearGradient(
        colors: [Color(hex: 0x2A1F5C), Color(hex: 0x16294A)],
        startPoint: .topLeading, endPoint: .bottomTrailing)
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xff) / 255.0
        let green = Double((hex >> 8) & 0xff) / 255.0
        let blue = Double(hex & 0xff) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
