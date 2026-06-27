import SwiftUI

enum PillButtonKind {
    case primary
    case secondary
}

/// pill CTA. primary는 오로라 그라데이션 + 글로우, secondary는 글래스.
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
        .foregroundStyle(kind == .primary ? Color.white : Theme.brandInk)
        .background(background)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Theme.hairline, lineWidth: kind == .secondary ? 1 : 0))
        .shadow(color: kind == .primary ? Theme.violet.opacity(isHovering ? 0.55 : 0.40) : .clear,
                radius: 14, y: 6)
        .opacity(isEnabled ? 1 : 0.4)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
        .disabled(!isEnabled)
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .primary:
            Theme.aurora.opacity(isHovering ? 0.92 : 1)
        case .secondary:
            (isHovering ? Color(white: 1, opacity: 0.10) : Color(white: 1, opacity: 0.04))
        }
    }
}
