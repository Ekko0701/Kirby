import SwiftUI

/// 글래스 카드(반투명 그라데이션 + 머티리얼 + 헤어라인 + 그림자).
struct SurfaceCard<Content: View>: View {
    var radius: CGFloat = Radius.md16
    var padding: CGFloat = Spacing.xl24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Theme.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 18, y: 10)
    }
}
