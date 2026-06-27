import SwiftUI

struct InstalledAppsView: View {
    var body: some View {
        ComingSoonView(
            title: "Installed Apps",
            systemImage: "square.grid.2x2",
            description: "설치된 앱(\(AppInventory.installedCount())개)을 보고, 앱과 그 관련 파일(캐시·설정·지원 파일)까지 함께 제거하는 기능입니다."
        )
    }
}
