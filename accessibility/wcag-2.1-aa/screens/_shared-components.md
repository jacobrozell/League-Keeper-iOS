# Shared components

Cross-screen UI that affects multiple WCAG rows.

| Component | Source | Used on |
|-----------|--------|---------|
| `PrimaryActionButton` | `Components/PrimaryActionButton.swift` | flows, modals |
| `SecondaryButton` | `Components/SecondaryButton.swift` | modals |
| `DestructiveActionButton` | `Components/DestructiveActionButton.swift` | settings, delete flows |
| `PlayerRow` | `Components/PlayerRow.swift` | players, add-players, attendance |
| `TournamentCell` | `Components/TournamentCell.swift` | tournaments |
| `StandingsRow` | `Components/StandingsRow.swift` | stats, standings |
| `CoachMarkBanner` | `Components/CoachMarkBanner.swift` | attendance, round |
| `TableBonusesSection` | `Components/TableBonusesSection.swift` | round scoring |
| `StatTile` | `DesignSystem/DesignComponents.swift` | stats, dashboards |
| `LabeledStepper` / `LabeledToggle` | `Components/` | forms |
| `PlacementPicker` | `Components/PlacementPicker.swift` | pod scoring |
| `AchievementListRow` | `Components/AchievementListRow.swift` | achievements |
| `BarChartView` / `LineChartView` / `PieChartView` | `Components/Charts/` | stats |
| `EmptyStateView` | `Components/EmptyStateView.swift` | empty lists |
| `AccessibleColors` | `Constants/AppConstants.swift` | all screens |

## Criterion checklist

| ID | Status | Notes |
|----|--------|-------|
| P-1.1.1 | Partial | Buttons labeled; coach marks announce; charts partial |
| P-1.4.1 | Pass | Placement uses text + badges |
| P-1.4.3 | Partial | Semantic `UIColor` tokens |
| P-1.4.4 | Partial | Rows scale to **AXXXL** (2026-06-18); `EmptyStateView` caps AX3; `StatTile` reflow |
| R-4.1.2 | Partial | Achievement hints in `TableBonusesSection` |
| O-2.5.3 | Pass | Button labels match visible title |
| LKX-TARGET-44 | Pass | Primary/destructive buttons ≥ 44pt |
| LKX-CHART-A11Y | Partial | Charts have basic summaries |

## Open work

- [x] 44pt minimum on primary/destructive/secondary buttons
- [x] `accessibilityIdentifier` on `LabeledStepper`, `LabeledToggle`, `PlayerRow`
- [x] Row Dynamic Type cap raised from AX2 → AX5 (2026-06-18)
- [x] `CoachMarkBanner` VoiceOver announcement (2026-06-18)
- [x] `TableBonusesSection` achievement descriptions + hints (2026-06-18)
- [x] `StatTile` reflow at accessibility sizes (2026-06-18)
- [ ] Chart accessibility values that read point/segment data (device VO)
- [ ] `EmptyStateView` cap review at AXXXL
- [ ] `PlacementPicker` VoiceOver state for selected placement

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | Codebase audit |
| 2026-06-18 | Agent | Partial | Near-blind audit; row caps + StatTile + coach marks |
