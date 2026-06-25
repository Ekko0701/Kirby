import SwiftUI

/// 앱 전역의 가벼운 UI 상태. 기능별 무거운 상태는 각 Coordinator가 보유한다.
@MainActor
@Observable
final class AppState {
    var selectedFeature: Feature = .cleanup
}
