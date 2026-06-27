import SwiftUI

/// 한 앱 + 관련 파일을 검토하고 휴지통으로 제거한다.
struct AppUninstallView: View {
    let app: InstalledApp
    let model: UninstallerModel
    @State private var showConfirm = false

    var body: some View {
        content
            .navigationTitle(app.name)
            .task { if model.selected?.id != app.id { model.select(app) } }
            .confirmationDialog(
                "\(app.name)을(를) 제거할까요?",
                isPresented: $showConfirm, titleVisibility: .visible
            ) {
                Button("\(ByteFormat.string(model.totalRemoveBytes)) 휴지통으로 이동", role: .destructive) {
                    model.uninstall()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("앱과 선택한 관련 파일을 휴지통으로 옮깁니다(복구 가능).")
            }
    }

    @ViewBuilder
    private var content: some View {
        if let summary = model.summary {
            SummaryView(summary: summary) { model.dismissSummary() }
        } else if model.isScanning {
            CleanProgressView(title: "관련 파일 찾는 중…", progress: 0)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                header
                List {
                    Section("앱") {
                        row(name: app.name + ".app", bytes: model.appSize, selected: true, toggle: nil)
                    }
                    if !model.related.isEmpty {
                        Section("관련 파일 \(model.related.count)개") {
                            ForEach(model.related) { item in
                                row(name: item.displayName, bytes: item.sizeBytes,
                                    selected: item.isSelected) { model.toggle(item) }
                            }
                        }
                    }
                }
                .listStyle(.inset)
                footer
            }
            .background(Theme.canvas)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs6) {
            Text(app.bundleID ?? "—").font(VFont.monoLabel14).foregroundStyle(Theme.slate)
            Text("제거 시 총 \(ByteFormat.string(model.totalRemoveBytes)) 확보")
                .font(VFont.body16).foregroundStyle(Theme.bodyMuted)
        }
        .padding([.horizontal, .top], 32).padding(.bottom, Spacing.lg16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row(name: String, bytes: Int64, selected: Bool, toggle: (() -> Void)?) -> some View {
        HStack(spacing: Spacing.md12) {
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selected ? Theme.actionBlue : Theme.muted)
                .opacity(toggle == nil ? 0.5 : 1)
            Text(name).font(VFont.body16).foregroundStyle(Theme.brandInk)
                .lineLimit(1).truncationMode(.middle)
            Spacer()
            Text(ByteFormat.string(bytes)).font(VFont.monoLabel14).foregroundStyle(Theme.slate)
        }
        .padding(.vertical, Spacing.xxs2)
        .contentShape(Rectangle())
        .onTapGesture { toggle?() }
    }

    private var footer: some View {
        HStack {
            Spacer()
            PillButton(title: "앱 제거 (\(ByteFormat.string(model.totalRemoveBytes)))", kind: .primary) {
                showConfirm = true
            }
            .frame(width: 300)
        }
        .padding(24).background(Theme.canvas)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.hairline), alignment: .top)
    }
}
