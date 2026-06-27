import SwiftUI

/// 삭제(정리) 중 전체 화면 진행 표시. 오로라 그라데이션 배경 + 회전 링·펄스 코어·궤도 입자.
struct CleaningProgressView: View {
    let title: String
    var subtitle: String? = nil

    @State private var spin = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: Spacing.xl24) {
                indicator
                VStack(spacing: Spacing.xs6) {
                    Text(title)
                        .font(VFont.cardHeading32)
                        .foregroundStyle(Theme.brandInk)
                    if let subtitle {
                        Text(subtitle)
                            .font(VFont.body16)
                            .foregroundStyle(Theme.bodyMuted)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) { spin = true }
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) { pulse = true }
        }
    }

    private var indicator: some View {
        ZStack {
            // 트랙
            Circle()
                .stroke(Theme.hairline, lineWidth: 10)
                .frame(width: 132, height: 132)

            // 회전하는 오로라 호
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(Theme.ringGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 132, height: 132)
                .rotationEffect(.degrees(spin ? 360 : 0))
                .shadow(color: Theme.violet.opacity(0.6), radius: 14)

            // 펄스 코어
            Circle()
                .fill(Theme.aurora)
                .frame(width: 46, height: 46)
                .scaleEffect(pulse ? 1.18 : 0.82)
                .opacity(pulse ? 0.95 : 0.5)
                .blur(radius: 1)

            // 궤도 입자(우주 느낌)
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .offset(y: -66)
                    .rotationEffect(.degrees(Double(index) / 3 * 360 + (spin ? 360 : 0)))
                    .opacity(0.85)
            }
        }
        .frame(width: 132, height: 132)
    }
}
