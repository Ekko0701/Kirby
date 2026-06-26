import SwiftUI

struct OrphanFinderView: View {
    var body: some View {
        ComingSoonView(
            title: "Orphan Finder",
            systemImage: "magnifyingglass",
            description: "이미 삭제된 앱이 남긴 잔여 파일(고아 파일)을 Library에서 찾아내 정리하는 기능입니다."
        )
    }
}
