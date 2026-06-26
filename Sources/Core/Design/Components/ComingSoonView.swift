import SwiftUI

/// 아직 구현되지 않은 기능의 안내 화면.
struct ComingSoonView: View {
    let title: String
    let systemImage: String
    let description: String

    var body: some View {
        CenteredScreen {
            Image(systemName: systemImage)
                .font(.system(size: 52))
                .foregroundStyle(Theme.muted)
            Text(title).font(VFont.cardHeading32).foregroundStyle(Theme.brandInk)
            Text("준비 중입니다").font(VFont.bodyLarge18).foregroundStyle(Theme.coral)
            Text(description)
                .font(VFont.body16)
                .foregroundStyle(Theme.bodyMuted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 440)
        }
    }
}
