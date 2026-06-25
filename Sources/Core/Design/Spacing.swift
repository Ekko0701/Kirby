import CoreGraphics

/// 8px 기반 간격 스케일(DESIGN.md). 매직넘버 대신 항상 이 토큰을 쓴다.
enum Spacing {
    static let xxs2: CGFloat = 2
    static let xs6: CGFloat = 6
    static let sm8: CGFloat = 8
    static let md12: CGFloat = 12
    static let lg16: CGFloat = 16
    static let xl24: CGFloat = 24
    static let xxl32: CGFloat = 32
    static let section80: CGFloat = 80
}

/// 라운드 반경 스케일. 미디어 카드는 lg22, 주 CTA는 pill32.
enum Radius {
    static let xs4: CGFloat = 4
    static let sm8: CGFloat = 8
    static let md16: CGFloat = 16
    static let lg22: CGFloat = 22
    static let xl30: CGFloat = 30
    static let pill32: CGFloat = 32
    static let full: CGFloat = 9999
}
