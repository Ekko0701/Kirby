import SwiftUI

/// 디스크 사용량 애니메이션 링(오로라 그라데이션).
struct StorageRing: View {
    let usedFraction: Double
    @State private var animated: Double = 0

    var body: some View {
        ZStack {
            Circle().stroke(Theme.hairline, lineWidth: 18)
            Circle()
                .trim(from: 0, to: animated)
                .stroke(Theme.ringGradient, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.violet.opacity(0.5), radius: 8)
            VStack(spacing: 2) {
                Text("\(Int((usedFraction * 100).rounded()))%")
                    .font(VFont.cardHeading32).foregroundStyle(Theme.brandInk)
                Text("사용 중").font(VFont.caption14).foregroundStyle(Theme.bodyMuted)
            }
        }
        .padding(9)
        .onAppear { withAnimation(.easeOut(duration: 0.8)) { animated = usedFraction } }
        .onChange(of: usedFraction) { _, newValue in
            withAnimation(.easeOut(duration: 0.8)) { animated = newValue }
        }
    }
}
