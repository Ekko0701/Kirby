import SwiftUI

/// 도넛 차트의 한 세그먼트(데이터).
struct DonutSegment: Identifiable, Equatable {
    let id: String
    let label: String
    let bytes: Int64
    let color: Color
}

/// 도넛 차트의 한 호(누적 비율).
struct DonutArc: Identifiable, Equatable {
    let id: String
    let start: Double
    let end: Double
}

/// 도넛 비율 계산. View 밖의 순수 함수라 MainActor 격리 없이 테스트 가능하다.
enum DonutMath {
    static func arcs(for segments: [DonutSegment]) -> [DonutArc] {
        let total = segments.reduce(Int64(0)) { $0 + $1.bytes }
        guard total > 0 else { return [] }
        var cursor = 0.0
        return segments.map { segment in
            let fraction = Double(segment.bytes) / Double(total)
            let arc = DonutArc(id: segment.id, start: cursor, end: cursor + fraction)
            cursor += fraction
            return arc
        }
    }
}
