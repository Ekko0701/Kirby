import SwiftUI
import AppKit

/// 시스템이 관리하는 purgeable 공간 안내(앱이 직접 비울 수 없음).
struct PurgeableSpaceView: View {
    @State private var purgeable: Int64 = 0

    var body: some View {
        ScrollingScreen {
            Text("Purgeable Space")
                .font(VFont.sectionDisplay60).foregroundStyle(Theme.brandInk)
            Text("macOS가 저장 공간이 필요할 때 자동으로 비우는 '비울 수 있는' 공간입니다. 앱이 직접 삭제할 수는 없습니다.")
                .font(VFont.bodyLarge18).foregroundStyle(Theme.bodyMuted)

            SurfaceCard(radius: Radius.lg22, padding: Spacing.xxl32) {
                VStack(alignment: .leading, spacing: Spacing.sm8) {
                    Text(ByteFormat.string(purgeable))
                        .font(VFont.heroDisplay96).foregroundStyle(Theme.deepGreen)
                        .minimumScaleFactor(0.4).lineLimit(1)
                    Text("비울 수 있는 공간(추정)")
                        .font(VFont.caption14).foregroundStyle(Theme.bodyMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            FeatureBand {
                VStack(alignment: .leading, spacing: Spacing.md12) {
                    Text("어떻게 비우나요?").font(VFont.featureHeading24)
                    Text("이 공간은 시스템이 관리합니다. 저장 공간이 부족하면 macOS가 자동으로 정리하며, 시스템 설정의 '저장 공간'에서 직접 관리할 수도 있습니다.")
                        .font(VFont.body16)
                }
            }

            PillButton(title: "저장 공간 설정 열기", kind: .primary) {
                if let url = URL(string: "x-apple.systempreferences:com.apple.settings.Storage") {
                    NSWorkspace.shared.open(url)
                }
            }
            .frame(width: 240)
        }
        .task { purgeable = DiskSpace.purgeableEstimate() }
    }
}
