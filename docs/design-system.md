# Design system

UI conventions and reusable components for League Keeper. Constants live in `AppConstants`; components in `BudgetLeagueTracker/Components/`.

---

## Principles

- **Native first** — SwiftUI system styles (`.borderedProminent`, `.insetGrouped` lists).
- **Semantic colors** — `AppConstants.AccessibleColors` wraps UIKit semantic colors for light/dark adaptation.
- **No magic numbers** — Layout and scoring literals belong in `AppConstants`.
- **44pt touch targets** — Primary actions use `AppConstants.UI.minTouchTargetHeight`.

---

## Color tokens

| Token | Use | Source |
|-------|-----|--------|
| `secondaryText` | Hints, subtitles | `.secondaryLabel` |
| `activeStatus` / `activeStatusBackground` | Ongoing badges | `.systemGreen` |
| `winnerAccent` | Tournament winner | `.systemYellow` |
| `placementAccent` | Placement legend | `.systemBlue` |
| `achievementAccent` | Achievement legend | `.systemGreen` |
| `statOrange` / `statYellow` / `semanticGray` | Chart differentiation | System colors |

Contrast rationale: [accessibility/wcag-2.1-aa/evidence/contrast/](../accessibility/wcag-2.1-aa/evidence/contrast/)

---

## Components

| Component | Purpose | Accessibility |
|-----------|---------|---------------|
| `PrimaryActionButton` | Main CTA | Label from title; 44pt min height |
| `SecondaryButton` | Secondary CTA | Same |
| `DestructiveActionButton` | Delete / reset | Red prominent style |
| `PlayerRow` | Player list cell | Modes: display (avatar, rank, form, sparkline), removable, toggleable |
| `PlayerAvatarView` | Initials avatar chip | Stable color from player id |
| `PlayerFormDotsView` | Recent placement form | WCAG summary label |
| `PlayerSparklineView` | List-row points trend | Mini Swift Charts line |
| `PlayerIdentityCard` | Player detail hero | Rank + win rate + last played |
| `PlayerAchievementGallerySection` | Earned achievement badges | |
| `PlayerHeadToHeadSection` | Compare two players | |
| `TournamentCell` | Tournament list row | Status badge |
| `StandingsRow` | Ranked player row | Rank + name + points |
| `AchievementListRow` | Achievement with toggle/delete | |
| `LabeledStepper` | Numeric form field | Label + identifier |
| `LabeledToggle` | Boolean form field | Label + identifier |
| `PlacementPicker` | 1st–4th selection | |
| `EmptyStateView` | Zero-data states | Message + hint |
| `HintText` | Secondary explanatory text | |
| `ModalActionBar` | Sheet primary + secondary actions | |
| `BarChartView` / `LineChartView` / `PieChartView` | Stats charts | Partial VO — see WCAG tracker |

---

## Typography

- Use SwiftUI semantic fonts: `.body`, `.headline`, `.caption`.
- Dynamic Type: key rows cap at `.accessibility2` where layout would break — verify at AXXXL (`accessibility/Manual_todo.md`).

---

## Adding a component

1. Place in `BudgetLeagueTracker/Components/`.
2. Accept data + callbacks; no direct `ModelContext` in components.
3. Add `accessibilityLabel` and `accessibilityIdentifier` for interactive elements.
4. Add snapshot test in `ComponentSnapshotTests` (light + dark).
5. Update [accessibility/wcag-2.1-aa/screens/_shared-components.md](../accessibility/wcag-2.1-aa/screens/_shared-components.md).

---

## See also

- [specs/AccessibilitySpec.md](../specs/AccessibilitySpec.md)
- [design preview] — `#Preview` blocks in each component file
