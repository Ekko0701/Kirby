import SwiftUI

/// 스캔 결과를 범주별로 보여주고 사용자가 항목을 선택하는 화면.
struct ScanResultsView: View {
    let coordinator: CleanupCoordinator
    let onClean: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            List {
                ForEach(ScanCategory.allCases) { category in
                    let items = coordinator.itemsByCategory[category] ?? []
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { item in
                                row(item)
                            }
                        } header: {
                            categoryHeader(category, items: items)
                        }
                    }
                }
            }
            .listStyle(.inset)
            footer
        }
        .background(Theme.canvas)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs6) {
            Text("정리할 항목 선택")
                .font(VFont.sectionHeading48)
                .foregroundStyle(Theme.brandInk)
            Text("총 \(ByteFormat.string(coordinator.totalBytes)) 발견 · 선택 \(ByteFormat.string(coordinator.selectedBytes))")
                .font(VFont.body16)
                .foregroundStyle(Theme.bodyMuted)
        }
        .padding([.horizontal, .top], 32)
        .padding(.bottom, Spacing.lg16)
    }

    private func categoryHeader(_ category: ScanCategory, items: [ScanItem]) -> some View {
        let total = items.reduce(Int64(0)) { $0 + $1.sizeBytes }
        let allSelected = items.allSatisfy(\.isSelected)
        return HStack {
            Label(category.title, systemImage: category.systemImage)
                .font(VFont.featureHeading24)
                .foregroundStyle(Theme.brandInk)
            Spacer()
            Text(ByteFormat.string(total))
                .font(VFont.monoLabel14)
                .foregroundStyle(Theme.slate)
            Button(allSelected ? "모두 해제" : "모두 선택") {
                coordinator.setSelected(!allSelected, for: category)
            }
            .buttonStyle(.plain)
            .font(VFont.button14)
            .foregroundStyle(Theme.actionBlue)
            .accessibilityLabel("\(category.title) \(allSelected ? "모두 해제" : "모두 선택")")
        }
        .padding(.vertical, Spacing.sm8)
    }

    private func row(_ item: ScanItem) -> some View {
        HStack(spacing: Spacing.md12) {
            Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isSelected ? Theme.actionBlue : Theme.muted)
            Text(item.displayName)
                .font(VFont.body16)
                .foregroundStyle(Theme.brandInk)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text(ByteFormat.string(item.sizeBytes))
                .font(VFont.monoLabel14)
                .foregroundStyle(Theme.slate)
        }
        .padding(.vertical, Spacing.xxs2)
        .contentShape(Rectangle())
        .onTapGesture { coordinator.toggle(item) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(item.isSelected ? "선택됨" : "선택 안 됨")
        .accessibilityHint("두 번 탭하면 선택을 바꿉니다")
    }

    private var footer: some View {
        HStack {
            PillButton(title: "다시 스캔", kind: .secondary) { coordinator.scan() }
                .frame(maxWidth: 140)
            Spacer()
            PillButton(
                title: "선택 항목 정리 (\(ByteFormat.string(coordinator.selectedBytes)))",
                kind: .primary,
                isEnabled: !coordinator.selectedItems.isEmpty,
                action: onClean
            )
            .frame(maxWidth: 320)
        }
        .padding(24)
        .background(Theme.canvas)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.hairline), alignment: .top)
    }
}
