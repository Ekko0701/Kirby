import SwiftUI

/// 딥그린 풀폭 밴드(DESIGN.md dark-feature-band). 흰 캔버스를 끊어주는 강조 영역.
struct FeatureBand<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Spacing.xxl32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.deepGreen)
            .foregroundStyle(Theme.onDark)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg22, style: .continuous))
    }
}
