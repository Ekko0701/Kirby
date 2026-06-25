import SwiftUI

/// FDA 미허용 시 보여주는 안내 화면.
struct OnboardingView: View {
    let onRecheck: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xl24) {
            Text("전체 디스크 접근 권한이 필요해요")
                .font(VFont.sectionHeading48)
                .foregroundStyle(Theme.brandInk)

            Text("Kirby가 캐시·로그 같은 정리 대상을 읽으려면 macOS의 '전체 디스크 접근' 권한이 필요합니다. 이 권한은 사용자가 시스템 설정에서 직접 켜야 합니다.")
                .font(VFont.bodyLarge18)
                .foregroundStyle(Theme.bodyMuted)
                .fixedSize(horizontal: false, vertical: true)

            FeatureBand {
                VStack(alignment: .leading, spacing: Spacing.md12) {
                    Text("켜는 방법").font(VFont.featureHeading24)
                    Text("1. '시스템 설정 열기'를 누릅니다.\n2. 개인정보 보호 및 보안 → 전체 디스크 접근으로 이동합니다.\n3. 목록에서 Kirby를 켭니다.\n4. 돌아와서 '권한을 켰어요'를 누릅니다.")
                        .font(VFont.body16)
                }
            }

            HStack(spacing: Spacing.md12) {
                PillButton(title: "시스템 설정 열기", kind: .primary) {
                    PermissionChecker.openSettings()
                }
                .frame(maxWidth: 220)

                PillButton(title: "권한을 켰어요", kind: .secondary, action: onRecheck)
                    .frame(maxWidth: 180)
            }

            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.canvas)
    }
}
