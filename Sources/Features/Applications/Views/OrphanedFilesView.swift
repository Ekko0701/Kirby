import SwiftUI

/// 삭제된 앱이 남긴 고아 파일을 찾아 휴지통으로 정리한다.
struct OrphanedFilesView: View {
    @State private var model = OrphanFinderModel()
    @State private var showConfirm = false

    var body: some View {
        content
            .confirmationDialog(
                "선택한 고아 파일을 정리할까요?",
                isPresented: $showConfirm, titleVisibility: .visible
            ) {
                Button("\(ByteFormat.string(model.selectedBytes)) 휴지통으로 이동", role: .destructive) {
                    model.deleteSelected()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("\(model.selectedItems.count)개 항목을 휴지통으로 옮깁니다(복구 가능).")
            }
    }

    @ViewBuilder
    private var content: some View {
        if let summary = model.summary {
            SummaryView(summary: summary) { model.dismissSummary() }
        } else if model.isScanning {
            CleanProgressView(title: "고아 파일 스캔 중…", progress: 0)
        } else if !model.hasScanned {
            intro
        } else if model.orphans.isEmpty {
            empty
        } else {
            results
        }
    }

    private var intro: some View {
        ScrollingScreen {
            Text("Orphaned Files")
                .font(VFont.sectionDisplay60).foregroundStyle(Theme.brandInk)
            Text("이미 삭제된 앱이 ~/Library에 남긴 잔여 파일(번들ID로 추정)을 찾습니다. 안전을 위해 기본 선택은 해제되어 있으니 직접 검토 후 정리하세요.")
                .font(VFont.bodyLarge18).foregroundStyle(Theme.bodyMuted)
            PillButton(title: "스캔 시작", kind: .primary) { model.scan() }.frame(width: 220)
        }
    }

    private var empty: some View {
        CenteredScreen {
            Image(systemName: "checkmark.circle").font(.system(size: 40)).foregroundStyle(Theme.deepGreen)
            Text("고아 파일을 찾지 못했습니다").font(VFont.bodyLarge18).foregroundStyle(Theme.bodyMuted)
        }
    }

    private var results: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.xs6) {
                Text("Orphaned Files").font(VFont.sectionHeading48).foregroundStyle(Theme.brandInk)
                Text("\(model.orphans.count)개 발견 · 선택 \(ByteFormat.string(model.selectedBytes))")
                    .font(VFont.body16).foregroundStyle(Theme.bodyMuted)
            }
            .padding([.horizontal, .top], 32).padding(.bottom, Spacing.lg16)
            .frame(maxWidth: .infinity, alignment: .leading)

            List(model.orphans) { item in
                HStack(spacing: Spacing.md12) {
                    Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isSelected ? Theme.actionBlue : Theme.muted)
                    Text(item.displayName).font(VFont.body16).foregroundStyle(Theme.brandInk)
                        .lineLimit(1).truncationMode(.middle)
                    Spacer()
                    Text(ByteFormat.string(item.sizeBytes)).font(VFont.monoLabel14).foregroundStyle(Theme.slate)
                }
                .padding(.vertical, Spacing.xxs2)
                .contentShape(Rectangle())
                .onTapGesture { model.toggle(item) }
            }
            .listStyle(.inset)
                .scrollContentBackground(.hidden)

            HStack {
                Button("다시 스캔") { model.scan() }
                    .buttonStyle(.plain).font(VFont.button14).foregroundStyle(Theme.actionBlue)
                Button(model.allSelected ? "모두 해제" : "모두 선택") {
                    model.setAllSelected(!model.allSelected)
                }
                .buttonStyle(.plain).font(VFont.button14).foregroundStyle(Theme.actionBlue)
                Spacer()
                PillButton(title: "정리 (\(ByteFormat.string(model.selectedBytes)))",
                           kind: .primary, isEnabled: !model.selectedItems.isEmpty) {
                    showConfirm = true
                }
                .frame(width: 280)
            }
            .padding(24).background(.ultraThinMaterial)
            .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.hairline), alignment: .top)
        }
        .background(AuroraBackground())
    }
}
