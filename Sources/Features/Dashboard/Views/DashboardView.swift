import SwiftUI

/// 디스크 사용량 + 정리 가능 용량 + 원클릭 전체 정리.
struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var disk: DiskUsage = .empty
    @State private var cleanPhase: CleanPhase = .idle
    @State private var cleanSummary: CleanSummary?
    @State private var showConfirm = false

    private enum CleanPhase { case idle, cleaning, done }

    var body: some View {
        Group {
            if cleanPhase == .cleaning {
                CleaningProgressView(title: "정리 중…", subtitle: "선택한 항목을 정리하고 있습니다")
            } else {
                ScrollingScreen {
                    Text("Dashboard")
                        .font(VFont.sectionDisplay60)
                        .foregroundStyle(Theme.brandInk)

                    diskCard
                    reclaimableCard
                }
            }
        }
        .confirmationDialog(
            "선택한 항목을 한 번에 정리할까요?",
            isPresented: $showConfirm, titleVisibility: .visible
        ) {
            Button("\(ByteFormat.string(appState.cleanup.selectedBytes)) 정리", role: .destructive) {
                startCleanAll()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("선택된 \(appState.cleanup.selectedItems.count)개 항목(총 \(ByteFormat.string(appState.cleanup.selectedBytes)))을 정리합니다. 캐시·로그·정크는 재생성되며, 대용량·앱 관련 항목은 휴지통으로 이동합니다.")
        }
        .task {
            disk = DiskSpace.current()
            if case .idle = appState.cleanup.state { appState.cleanup.scan() }
        }
    }

    // MARK: 디스크 카드

    private var diskCard: some View {
        SurfaceCard(radius: Radius.lg22, padding: Spacing.xxl32) {
            HStack(spacing: Spacing.xxl32) {
                StorageRing(usedFraction: disk.usedFraction)
                    .frame(width: 170, height: 170)
                VStack(alignment: .leading, spacing: Spacing.md12) {
                    Text("디스크").font(VFont.featureHeading24).foregroundStyle(Theme.brandInk)
                    statRow("사용 중", disk.used, Theme.deepGreen)
                    statRow("여유", disk.free, Theme.muted)
                    statRow("전체", disk.total, Theme.brandInk)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statRow(_ label: String, _ bytes: Int64, _ color: Color) -> some View {
        HStack(spacing: Spacing.sm8) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label).font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            Text(ByteFormat.string(bytes)).font(VFont.monoLabel14).foregroundStyle(Theme.brandInk)
        }
    }

    // MARK: 정리 가능 카드 + 원클릭

    @ViewBuilder
    private var reclaimableCard: some View {
        let coordinator = appState.cleanup
        SurfaceCard(radius: Radius.lg22, padding: Spacing.xxl32) {
            VStack(alignment: .leading, spacing: Spacing.lg16) {
                HStack {
                    Text("정리 가능 용량").font(VFont.featureHeading24).foregroundStyle(Theme.brandInk)
                    Spacer()
                    if case .scanning = coordinator.state {
                        ProgressView().controlSize(.small)
                        Button("취소") { coordinator.cancelScan() }
                            .buttonStyle(.plain).font(VFont.button14).foregroundStyle(Theme.actionBlue)
                    }
                }
                reclaimableBody(coordinator)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func reclaimableBody(_ coordinator: CleanupCoordinator) -> some View {
        switch cleanPhase {
        case .cleaning:
            HStack(spacing: Spacing.md12) {
                ProgressView().controlSize(.small)
                Text("정리 중…").font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            }
        case .done:
            doneView
        case .idle:
            scannedBody(coordinator)
        }
    }

    private var doneView: some View {
        HStack(spacing: Spacing.md12) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 28)).foregroundStyle(Theme.deepGreen)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(cleanSummary?.itemsCleaned ?? 0)개 정리 · \(ByteFormat.string(cleanSummary?.bytesFreed ?? 0)) 확보")
                    .font(VFont.bodyLarge18).foregroundStyle(Theme.brandInk)
                if let errors = cleanSummary?.errors, !errors.isEmpty {
                    Text("\(errors.count)개는 사용 중이거나 권한이 없어 건너뜀")
                        .font(VFont.caption14).foregroundStyle(Theme.coral)
                }
            }
            Spacer()
            PillButton(title: "완료", kind: .secondary) {
                cleanPhase = .idle
                disk = DiskSpace.current()
            }
            .frame(width: 120)
        }
    }

    @ViewBuilder
    private func scannedBody(_ coordinator: CleanupCoordinator) -> some View {
        switch coordinator.state {
        case .scanning:
            Text("스캔 중…").font(VFont.body16).foregroundStyle(Theme.bodyMuted)
        case .scanned, .completed:
            let segments = donutSegments(coordinator)
            if segments.isEmpty {
                Text("정리할 항목이 없습니다.").font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            } else {
                HStack(alignment: .top, spacing: Spacing.xxl32) {
                    CategoryDonut(segments: segments).frame(width: 160, height: 160)
                    VStack(alignment: .leading, spacing: Spacing.sm8) {
                        Text(ByteFormat.string(coordinator.totalBytes))
                            .font(VFont.cardHeading32).foregroundStyle(Theme.brandInk)
                        Text("발견 · 선택 \(ByteFormat.string(coordinator.selectedBytes))")
                            .font(VFont.caption14).foregroundStyle(Theme.bodyMuted)
                        ForEach(segments) { segment in
                            HStack(spacing: Spacing.sm8) {
                                Circle().fill(segment.color).frame(width: 10, height: 10)
                                Text(segment.label).font(VFont.body16).foregroundStyle(Theme.brandInk)
                                Spacer()
                                Text(ByteFormat.string(segment.bytes))
                                    .font(VFont.monoLabel14).foregroundStyle(Theme.slate)
                            }
                        }
                        PillButton(
                            title: "한 번에 정리 (\(ByteFormat.string(coordinator.selectedBytes)))",
                            kind: .primary,
                            isEnabled: !coordinator.selectedItems.isEmpty
                        ) { showConfirm = true }
                        .frame(maxWidth: 320)
                        .padding(.top, Spacing.sm8)
                        Text("위험·대용량 항목은 기본 해제이며, 각 범주 화면에서 직접 선택해 정리할 수 있습니다.")
                            .font(VFont.micro12).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                }
            }
        default:
            PillButton(title: "분석 시작", kind: .secondary) { coordinator.scan() }
                .frame(width: 160)
        }
    }

    private func startCleanAll() {
        cleanPhase = .cleaning
        Task {
            let summary = await appState.cleanup.cleanAllSelected()
            cleanSummary = summary
            cleanPhase = .done
            disk = DiskSpace.current()
        }
    }

    private func donutSegments(_ coordinator: CleanupCoordinator) -> [DonutSegment] {
        let colors: [ScanCategory: Color] = [
            .systemJunk: Theme.brandPrimary,
            .userCache: Theme.deepGreen,
            .aiApps: Theme.actionBlue,
            .mail: Theme.coral,
            .trash: Theme.slate,
            .xcode: Theme.darkNavy,
            .brew: Theme.coralSoft,
            .node: Theme.focusBlue,
            .docker: Theme.muted,
            .largeOld: Theme.errorRed,
        ]
        return ScanCategory.allCases.compactMap { category in
            let bytes = (coordinator.itemsByCategory[category] ?? [])
                .reduce(Int64(0)) { $0 + $1.sizeBytes }
            guard bytes > 0 else { return nil }
            return DonutSegment(
                id: category.rawValue, label: category.title,
                bytes: bytes, color: colors[category] ?? Theme.muted
            )
        }
    }
}
