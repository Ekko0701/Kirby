import SwiftUI

/// 다크 베이스 위에 오로라 라디얼 글로우를 얹은 배경.
struct AuroraBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.bg0, Theme.bg1, Theme.bg0],
                           startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Theme.violet.opacity(0.32), .clear],
                           center: .topLeading, startRadius: 0, endRadius: 540)
            RadialGradient(colors: [Theme.teal.opacity(0.18), .clear],
                           center: .bottomTrailing, startRadius: 0, endRadius: 560)
            RadialGradient(colors: [Theme.blue.opacity(0.16), .clear],
                           center: .topTrailing, startRadius: 0, endRadius: 440)
        }
        .ignoresSafeArea()
    }
}
