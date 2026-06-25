import SwiftUI

/// 흰 캔버스 + 헤어라인 보더의 평면 카드. 그림자 대신 보더로 깊이를 표현한다.
struct SurfaceCard<Content: View>: View {
    var radius: CGFloat = Radius.md16
    var padding: CGFloat = Spacing.xl24
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(Theme.canvas)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
    }
}
