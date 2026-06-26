import SwiftUI

/// 범주별 비율을 도넛으로 표시한다.
struct CategoryDonut: View {
    let segments: [DonutSegment]

    var body: some View {
        ZStack {
            Circle().stroke(Theme.hairline, lineWidth: 22)
            ForEach(DonutMath.arcs(for: segments)) { arc in
                Circle()
                    .trim(from: arc.start, to: arc.end)
                    .stroke(color(for: arc.id), style: StrokeStyle(lineWidth: 22, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding(11)
    }

    private func color(for id: String) -> Color {
        segments.first { $0.id == id }?.color ?? Theme.muted
    }
}
