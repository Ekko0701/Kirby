import SwiftUI

/// Cleanup 기능의 최상위 화면. 상태에 따라 하위 화면을 분기한다.
struct CleanupView: View {
    @State private var coordinator: CleanupCoordinator
    @State private var showConfirm = false

    init(coordinator: CleanupCoordinator? = nil) {
        _coordinator = State(initialValue: coordinator
            ?? CleanupCoordinator(modules: DefaultCleanerModules.all()))
    }

    var body: some View {
        content
            .confirmationDialog(
                "선택한 항목을 영구 삭제할까요?",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                Button("\(ByteFormat.string(coordinator.selectedBytes)) 영구 삭제", role: .destructive) {
                    coordinator.clean()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("\(coordinator.selectedItems.count)개 항목, 총 \(ByteFormat.string(coordinator.selectedBytes))를 삭제합니다. 복구할 수 없습니다.")
            }
    }

    @ViewBuilder
    private var content: some View {
        switch coordinator.state {
        case .idle:
            idleView
        case .scanning(let progress):
            CleanProgressView(title: "스캔 중…", progress: progress) {
                coordinator.cancelScan()
            }
        case .scanned:
            ScanResultsView(coordinator: coordinator) { showConfirm = true }
        case .cleaning(let progress):
            CleanProgressView(title: "정리 중…", progress: progress)
        case .completed:
            SummaryView(summary: coordinator.summary) { coordinator.reset() }
        case .failed(let message):
            failedView(message)
        }
    }

    private var idleView: some View {
        ScrollingScreen {
            Text("Kirby")
                .font(VFont.sectionDisplay60)
                .foregroundStyle(Theme.brandInk)
            Text("macOS를 가볍게. 안전하게.")
                .font(VFont.bodyLarge18)
                .foregroundStyle(Theme.bodyMuted)
            FeatureBand {
                VStack(alignment: .leading, spacing: Spacing.md12) {
                    Text("Cleanup").font(VFont.featureHeading24)
                    Text("캐시 · 로그 · 휴지통 · 개발자 정크를 스캔하고 안전하게 정리합니다. 스캔 후 직접 검토·선택하고, 확인을 거쳐야만 삭제합니다.")
                        .font(VFont.body16)
                }
            }
            PillButton(title: "스캔 시작", kind: .primary) { coordinator.scan() }
                .frame(width: 220)
        }
    }

    private func failedView(_ message: String) -> some View {
        CenteredScreen {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(Theme.errorRed)
            Text("문제가 발생했어요").font(VFont.cardHeading32)
            Text(message).font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            PillButton(title: "다시 시도", kind: .primary) { coordinator.scan() }
                .frame(width: 180)
        }
    }
}
