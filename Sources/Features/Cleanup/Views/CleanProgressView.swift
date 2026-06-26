import SwiftUI

/// 스캔/청소 진행 화면.
struct CleanProgressView: View {
    let title: String
    let progress: Double
    var onCancel: (() -> Void)? = nil

    var body: some View {
        CenteredScreen {
            Text(title).font(VFont.cardHeading32).foregroundStyle(Theme.brandInk)
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(Theme.deepGreen)
                .frame(maxWidth: 360)
            if let onCancel {
                PillButton(title: "취소", kind: .secondary, action: onCancel).frame(width: 160)
            }
        }
    }
}
