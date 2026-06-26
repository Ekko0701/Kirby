# Dashboard + 좌측 메뉴 설계 (PureMac 참고) — 2026-06-26

## 목표
PureMac을 참고해 Kirby에 Dashboard와 좌측 메뉴(인스펙터)를 구성한다. 범위: Dashboard는 실제
동작, 나머지 새 메뉴는 스캐폴딩(준비 중 화면). Cleanup은 기존 기능 연결.

## 좌측 메뉴 (Feature enum)
- Dashboard (`gauge.medium`) — 기본 선택, 실제 동작
- Cleanup (`sparkles`) — 기존
- Uninstaller (`xmark.bin`) — 준비 중
- Orphan Finder (`magnifyingglass`) — 준비 중
사이드바는 "정리 / 도구" 섹션으로 그룹핑.

## Dashboard
- 디스크 사용량 링: 루트 볼륨 총/사용/여유를 URLResourceValues로 즉시 계산해 애니메이션 링 + 수치.
- 정리 가능 용량 도넛: 진입 시 공유 CleanupCoordinator로 백그라운드 스캔 → 범주별 회수 가능
  용량을 도넛 + 범례. 스캔 중 진행 표시, 취소 가능.
- CTA "정리하러 가기" → Cleanup으로 전환(이미 스캔된 결과 공유).

## 아키텍처
- AppState가 공유 CleanupCoordinator 소유 → Dashboard 분석과 Cleanup이 같은 스캔 공유.
- 뷰는 ScrollingScreen/CenteredScreen 스캐폴드 사용(흰 화면 버그 방지).
- 신규 컴포넌트: StorageRing, CategoryDonut(순수 SwiftUI 도형), ComingSoonView.
- 색은 기존 Theme 토큰 재사용.

## 파일
- 신규: Features/Dashboard/Views/{DashboardView,StorageRing,CategoryDonut}.swift,
  Features/Dashboard/Models/DiskUsage.swift, Core/FileManagement/DiskSpace.swift,
  Core/Design/Components/ComingSoonView.swift, Features/{Uninstaller,OrphanFinder} placeholder.
- 수정: App/{Feature,AppState,RootView}.swift, Features/Cleanup/Views/CleanupView.swift(주입식).

## 테스트
- DiskUsage 계산 속성(used, usedFraction) 단위 테스트(합성 값).
- CategoryDonut 세그먼트 비율 계산 순수 함수 단위 테스트.

## 범위 제외 (YAGNI)
Uninstaller/Orphan Finder 실제 로직, Scheduled Cleaning, Settings.
