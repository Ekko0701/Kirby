import SwiftUI

struct UninstallerView: View {
    var body: some View {
        ComingSoonView(
            title: "Uninstaller",
            systemImage: "xmark.bin",
            description: "앱을 삭제할 때 캐시·설정·지원 파일 등 관련 파일까지 함께 찾아 깔끔하게 제거하는 기능입니다."
        )
    }
}
