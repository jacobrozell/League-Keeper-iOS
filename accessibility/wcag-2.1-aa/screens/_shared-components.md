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
| `LabeledStepper` / `LabeledToggle` | `Components/` | forms |
| `PlacementPicker` | `Components/PlacementPicker.swift` | pod scoring |
| `AchievementListRow` | `Components/AchievementListRow.swift` | achievements |
| `BarChartView` / `LineChartView` / `PieChartView` | `Components/Charts/` | stats |
| `EmptyStateView` | `Components/EmptyStateView.swift` | empty lists |
| `AccessibleColors` | `Constants/AppConstants.swift` | all screens |

## Criterion checklist

| ID | Status | Notes |
|----|--------|-------|
| P-1.1.1 | Partial | Buttons labeled; charts partial |
| P-1.4.1 | Pass | Placement uses text + badges |
| P-1.4.3 | Partial | Semantic `UIColor` tokens |
| P-1.4.4 | Partial | `minTouchTargetHeight` 44pt; Dynamic Type on rows |
| R-4.1.2 | Partial | Custom buttons expose label; charts open |
| O-2.5.3 | Pass | Button labels match visible title |
| LKX-TARGET-44 | Pass | Primary/destructive buttons ≥ 44pt |
| LKX-CHART-A11Y | Partial | Charts have basic identifiers; need data summaries |

## Open work

- [x] 44pt minimum on `PrimaryActionButton`, `SecondaryButton`, `DestructiveActionButton`
- [x] `accessibilityIdentifier` on `LabeledStepper`, `LabeledToggle`, `PlayerRow`
- [ ] Chart accessibility values that read point/segment data
- [ ] `EmptyStateView` accessibility grouping
- [ ] `PlacementPicker` VoiceOver state for selected placement

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | Codebase audit; automated component tests |
