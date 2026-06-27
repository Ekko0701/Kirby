import SwiftUI

/// 그라데이션 강조 밴드.
struct FeatureBand<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Spacing.xxl32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.bandGradient)
            .foregroundStyle(Theme.onDark)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.lg22, style: .continuous)
                    .strokeBorder(Theme.hairline, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.30), radius: 16, y: 8)
    }
}
