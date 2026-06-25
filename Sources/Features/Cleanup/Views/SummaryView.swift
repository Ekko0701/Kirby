import SwiftUI

/// 청소 완료 요약 화면.
struct SummaryView: View {
    let summary: CleanSummary?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.deepGreen)
            Text("정리 완료")
                .font(VFont.cardHeading32)
                .foregroundStyle(Theme.brandInk)

            if let summary {
                Text("\(summary.itemsCleaned)개 항목 · \(ByteFormat.string(summary.bytesFreed)) 확보")
                    .font(VFont.bodyLarge18)
                    .foregroundStyle(Theme.bodyMuted)
                if !summary.errors.isEmpty {
                    Text("\(summary.errors.count)개 항목은 사용 중이거나 권한이 없어 건너뛰었습니다.")
                        .font(VFont.caption14)
                        .foregroundStyle(Theme.coral)
                }
            }

            PillButton(title: "완료", kind: .primary, action: onDone)
                .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.canvas)
    }
}
