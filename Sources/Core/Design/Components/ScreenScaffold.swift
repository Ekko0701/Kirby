import SwiftUI

/// 위에서부터 쌓이는 스크롤 화면(오로라 배경).
struct ScrollingScreen<Content: View>: View {
    var spacing: CGFloat = Spacing.xl24
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: spacing) {
                content
            }
            .padding(40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
        .background(AuroraBackground())
    }
}

/// 중앙 정렬 화면(오로라 배경).
struct CenteredScreen<Content: View>: View {
    var spacing: CGFloat = Spacing.xl24
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AuroraBackground())
    }
}
