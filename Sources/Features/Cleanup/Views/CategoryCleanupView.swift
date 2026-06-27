import SwiftUI

/// 한 청소 범주의 스캔 결과를 보여주고, 그 범주만 선택·정리한다.
struct CategoryCleanupView: View {
    let category: ScanCategory
    let coordinator: CleanupCoordinator

    @State private var phase: Phase = .browsing
    @State private var showConfirm = false
    @State private var summary: CleanSummary?

    private enum Phase { case browsing, cleaning, done }

    var body: some View {
        content
            .confirmationDialog(
                "선택한 항목을 영구 삭제할까요?",
                isPresented: $showConfirm, titleVisibility: .visible
            ) {
                Button("\(ByteFormat.string(coordinator.selectedBytes(in: category))) 영구 삭제", role: .destructive) {
                    startClean()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("\(coordinator.selectedItems(in: category).count)개 항목, 총 \(ByteFormat.string(coordinator.selectedBytes(in: category)))를 삭제합니다. 복구할 수 없습니다.")
            }
            .task { coordinator.ensureScanned() }
    }

    @ViewBuilder
    private var content: some View {
        switch (coordinator.state, phase) {
        case (.scanning, _):
            CleanProgressView(title: "스캔 중…", progress: scanProgress) { coordinator.cancelScan() }
        case (_, .cleaning):
            CleanProgressView(title: "정리 중…", progress: 0)
        case (_, .done):
            SummaryView(summary: summary) { phase = .browsing }
        default:
            results
        }
    }

    private var scanProgress: Double {
        if case .scanning(let progress) = coordinator.state { return progress }
        return 0
    }

    @ViewBuilder
    private var results: some View {
        let items = coordinator.items(in: category)
        VStack(alignment: .leading, spacing: 0) {
            header(items)
            if items.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(items) { item in row(item) }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
                footer
            }
        }
        .background(AuroraBackground())
    }

    private func header(_ items: [ScanItem]) -> some View {
        let total = items.reduce(Int64(0)) { $0 + $1.sizeBytes }
        return VStack(alignment: .leading, spacing: Spacing.xs6) {
            Label(category.title, systemImage: category.systemImage)
                .font(VFont.sectionHeading48).foregroundStyle(Theme.brandInk)
            Text("총 \(ByteFormat.string(total)) · 선택 \(ByteFormat.string(coordinator.selectedBytes(in: category)))")
                .font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            Label("정리 전 관련 앱을 종료하면 더 안전합니다.", systemImage: "info.circle")
                .font(VFont.micro12).foregroundStyle(Theme.muted)
        }
        .padding([.horizontal, .top], 32).padding(.bottom, Spacing.lg16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md12) {
            Image(systemName: "checkmark.circle").font(.system(size: 40)).foregroundStyle(Theme.deepGreen)
            Text("정리할 항목이 없습니다").font(VFont.bodyLarge18).foregroundStyle(Theme.bodyMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func row(_ item: ScanItem) -> some View {
        HStack(spacing: Spacing.md12) {
            Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isSelected ? Theme.actionBlue : Theme.muted)
            Text(item.displayName)
                .font(VFont.body16).foregroundStyle(Theme.brandInk)
                .lineLimit(1).truncationMode(.middle)
            Spacer()
            Text(ByteFormat.string(item.sizeBytes))
                .font(VFont.monoLabel14).foregroundStyle(Theme.slate)
        }
        .padding(.vertical, Spacing.xxs2)
        .contentShape(Rectangle())
        .onTapGesture { coordinator.toggle(item) }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(item.isSelected ? "선택됨" : "선택 안 됨")
    }

    private var footer: some View {
        let allSelected = coordinator.items(in: category).allSatisfy(\.isSelected)
        return HStack {
            Button(allSelected ? "모두 해제" : "모두 선택") {
                coordinator.setSelected(!allSelected, for: category)
            }
            .buttonStyle(.plain).font(VFont.button14).foregroundStyle(Theme.actionBlue)
            Spacer()
            PillButton(
                title: "정리 (\(ByteFormat.string(coordinator.selectedBytes(in: category))))",
                kind: .primary,
                isEnabled: !coordinator.selectedItems(in: category).isEmpty
            ) { showConfirm = true }
            .frame(width: 280)
        }
        .padding(24).background(.ultraThinMaterial)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.hairline), alignment: .top)
    }

    private func startClean() {
        phase = .cleaning
        Task {
            let result = await coordinator.clean(category: category)
            summary = result
            phase = .done
        }
    }
}
