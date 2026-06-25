import SwiftUI

enum PillButtonKind {
    case primary    // 니어블랙 채움 pill — 최우선 액션
    case secondary  // 투명 + 헤어라인 보더 — 보조 액션
}

/// DESIGN.md의 pill CTA. hover 시 살짝 어두워지는 의도된 상태 변화를 가진다.
struct PillButton: View {
    let title: String
    var kind: PillButtonKind = .primary
    var isEnabled: Bool = true
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(VFont.button14)
                .padding(.vertical, Spacing.md12)
                .padding(.horizontal, Spacing.xl24)
                .frame(maxWidth: kind == .primary ? .infinity : nil)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(background)
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(Theme.hairline, lineWidth: kind == .secondary ? 1 : 0)
        )
        .opacity(isEnabled ? 1 : 0.4)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .disabled(!isEnabled)
    }

    private var foreground: Color {
        switch kind {
        case .primary: Theme.onDark
        case .secondary: Theme.brandInk
        }
    }

    private var background: Color {
        switch kind {
        case .primary: isHovering ? Theme.cohereBlack : Theme.brandPrimary
        case .secondary: isHovering ? Theme.softStone : Color.clear
        }
    }
}
