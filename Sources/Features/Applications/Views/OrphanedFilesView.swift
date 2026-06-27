import SwiftUI

struct OrphanedFilesView: View {
    var body: some View {
        ComingSoonView(
            title: "Orphaned Files",
            systemImage: "doc.questionmark",
            description: "이미 삭제된 앱이 남긴 잔여 파일(고아 파일)을 Library에서 찾아 정리하는 기능입니다."
        )
    }
}
