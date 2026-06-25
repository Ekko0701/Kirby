# 디자인 시스템 — 색·간격·글꼴 토큰

> "이 버튼 색 뭐 써야 해?"의 답은 항상 **토큰**입니다. 값을 직접 박지 마세요.

## 어디서 왔나

디자인 원본은 저장소 루트의 `DESIGN.md`입니다. Cohere라는 회사의 에디토리얼 웹 디자인 시스템을
네이티브 macOS 앱에 각색했습니다. 특징은:

- 흰 캔버스 기본 + 딥그린/니어블랙 강조 밴드
- 타이트한 큰 타이포
- pill(알약) 모양 CTA 버튼
- 그림자 대신 **헤어라인 보더**로 깊이 표현

## 색 — `Theme`

SwiftUI에 이미 `Color.primary`가 있어서 충돌을 피하려고 `Theme` 네임스페이스를 씁니다.

```swift
Text("안녕")
    .foregroundStyle(Theme.brandInk)   // 본문 기본색
    .background(Theme.canvas)          // 흰 배경
```

자주 쓰는 색:

| 토큰 | 용도 |
|---|---|
| `Theme.canvas` | 기본 흰 배경 |
| `Theme.brandInk` | 본문 텍스트 |
| `Theme.brandPrimary` | 주 CTA 버튼(니어블랙) |
| `Theme.deepGreen` | 강조 밴드 |
| `Theme.hairline` | 구분선·보더 |
| `Theme.coral` | 소량 액센트(남용 금지) |

색은 `Color(hex: 0xRRGGBB)` 헬퍼로 정의돼 있습니다. 새 색이 필요하면 `Colors.swift`의 `Theme`에만
추가하세요.

## 간격·반경 — `Spacing` / `Radius`

```swift
VStack(spacing: Spacing.xl24) { ... }
    .padding(Spacing.lg16)
    .clipShape(RoundedRectangle(cornerRadius: Radius.md16))
```

8px 기반입니다. 매직넘버(`.padding(16)`) 대신 `Spacing.lg16`을 쓰세요.

## 글꼴 — `VFont`

독점 폰트는 번들하지 않고 SF Pro / SF Mono로 폴백합니다.

```swift
Text("제목").font(VFont.sectionDisplay60)
Text("본문").font(VFont.body16)
Text("CACHE").font(VFont.monoLabel14)   // 기술 라벨은 모노
```

## 재사용 컴포넌트 (`Core/Design/Components`)

| 컴포넌트 | 설명 |
|---|---|
| `PillButton` | pill 모양 CTA. `.primary`(채움) / `.secondary`(보더). hover 상태 내장 |
| `SurfaceCard` | 흰 카드 + 헤어라인 보더 |
| `FeatureBand` | 딥그린 풀폭 강조 밴드 |

```swift
PillButton(title: "스캔 시작", kind: .primary) {
    coordinator.scan()
}
```

## 다크 모드?

MVP는 디자인 일관성을 위해 `.preferredColorScheme(.light)`로 **라이트 고정**입니다. 다크 지원은
나중에 `Theme` 토큰을 적응형 색으로 바꾸면 어렵지 않게 추가할 수 있습니다.
