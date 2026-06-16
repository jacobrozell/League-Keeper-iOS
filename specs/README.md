# Specs index

Catalog of product and system specifications for **League Keeper**. Specs are the source of truth for behavior; `docs/` files explain and guide.

**Governance:** [SpecGovernance.md](SpecGovernance.md)  
**Feature status:** [docs/feature-inventory.md](../docs/feature-inventory.md)  
**WCAG tracker:** [accessibility/wcag-2.1-aa/](../accessibility/wcag-2.1-aa/)

---

## MVP baselines (1.0)

- **Platform:** iOS 18+, iPhone and iPad (universal)
- **Persistence:** Local-only SwiftData; no account or sync
- **Language:** English
- **Accessibility target:** WCAG 2.1 AA ([AccessibilitySpec.md](AccessibilitySpec.md))
- **CI:** SwiftLint + unit tests on PR; UI/accessibility nightly
- **Analytics:** Firebase allowlist in Release builds only

---

## System specs

| Spec | Covers |
|------|--------|
| [ArchitectureSpec.md](ArchitectureSpec.md) | MVVM + Engine layers, folder layout, dependency rules |
| [TechStackSpec.md](TechStackSpec.md) | Swift 6, SwiftUI, SwiftData, XcodeGen, SPM |
| [DataSchemaSpec.md](DataSchemaSpec.md) | `@Model` types, invariants, bootstrap |
| [NavigationSpec.md](NavigationSpec.md) | `Screen` enum, TabView, sheets, `LeagueState` |
| [ScoringSpec.md](ScoringSpec.md) | Placement points, achievements, pods, weeks |
| [AchievementSpec.md](AchievementSpec.md) | Achievement catalog v2: icons, templates, tiers, exclusivity |
| [LoggingAnalyticsSpec.md](LoggingAnalyticsSpec.md) | AppLog, Firebase event allowlist |
| [TestPlanSpec.md](TestPlanSpec.md) | Unit, snapshot, UI, accessibility strategy |
| [AccessibilitySpec.md](AccessibilitySpec.md) | WCAG requirements and release gate |
| [iPadLayoutSpec.md](iPadLayoutSpec.md) | iPad + landscape layout, QA matrix, TestFlight gates |
| [AppStoreConnectSpec.md](AppStoreConnectSpec.md) | Metadata, URLs, privacy nutrition |
| [SpecGovernance.md](SpecGovernance.md) | Ownership, update rules, PR checklist |

---

## Feature areas (by folder)

| Area | Code | Docs |
|------|------|------|
| Tournaments | `Views/TournamentsView`, `TournamentDetailView`, … | [user-flows.md](../docs/user-flows.md) |
| Players | `Views/PlayersView`, `PlayerDetailView` | [data-model.md](../docs/data-model.md) |
| Stats & charts | `Views/StatsView`, `Components/Charts/` | [ScoringSpec.md](ScoringSpec.md) |
| Achievements | `Views/AchievementsView`, `AchievementFormView` (planned) | [AchievementSpec.md](AchievementSpec.md), [achievement-improvements-plan.md](../docs/achievement-improvements-plan.md) |
| Settings | `Views/SettingsView` | [AppStoreConnectSpec.md](AppStoreConnectSpec.md) |

---

## Related non-spec docs

- [docs/architecture.md](../docs/architecture.md) — architecture overview
- [docs/design-system.md](../docs/design-system.md) — UI components and tokens
- [docs/release/](../docs/release/) — TestFlight and ship checklists
