import SwiftUI

/// 위에서부터 쌓이는 스크롤 가능한 화면. (Spacer+maxHeight 패턴을 쓰지 않는다)
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
        .background(Theme.canvas)
    }
}

/// 화면 중앙에 내용을 두는 화면. (진행/요약/빈 상태용)
struct CenteredScreen<Content: View>: View {
    var spacing: CGFloat = Spacing.xl24
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas)
    }
}
