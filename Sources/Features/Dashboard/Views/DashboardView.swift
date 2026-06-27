import SwiftUI

/// 디스크 사용량 + 정리 가능 용량을 한눈에 보여주는 대시보드.
struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var disk: DiskUsage = .empty

    var body: some View {
        ScrollingScreen {
            Text("Dashboard")
                .font(VFont.sectionDisplay60)
                .foregroundStyle(Theme.brandInk)

            diskCard
            reclaimableCard
        }
        .task {
            disk = DiskSpace.current()
            if case .idle = appState.cleanup.state {
                appState.cleanup.scan()
            }
        }
    }

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
                        Text("정리 가능").font(VFont.caption14).foregroundStyle(Theme.bodyMuted)
                        ForEach(segments) { segment in
                            HStack(spacing: Spacing.sm8) {
                                Circle().fill(segment.color).frame(width: 10, height: 10)
                                Text(segment.label).font(VFont.body16).foregroundStyle(Theme.brandInk)
                                Spacer()
                                Text(ByteFormat.string(segment.bytes))
                                    .font(VFont.monoLabel14).foregroundStyle(Theme.slate)
                            }
                        }
                        PillButton(title: "User Cache 정리", kind: .primary) {
                            appState.selectedItem = .category(.userCache)
                        }
                        .frame(width: 220)
                        .padding(.top, Spacing.sm8)
                    }
                    Spacer()
                }
            }
        default:
            PillButton(title: "분석 시작", kind: .secondary) { coordinator.scan() }
                .frame(width: 160)
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
