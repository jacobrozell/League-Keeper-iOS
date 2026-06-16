# Feature inventory

Living register of League Keeper features: shipped, partial, and planned.

**Last reviewed:** 2026-06-16  
**App status:** Pre–TestFlight; core league flow complete; production infrastructure in place.

---

## How to maintain

1. **When shipping** — change status here and update the linked spec or WCAG screen file.
2. **When planning** — add a row as **Planned** with a link to `docs/ios-roadmap.md` or a new spec.
3. **PR rule** — feature PRs that change user-visible behavior should update this doc.

---

## Status legend

| Status | Meaning |
|--------|---------|
| **Shipped** | Built and reachable in the app |
| **Partial** | Exists but missing polish, tests, or a11y sign-off |
| **Planned** | On roadmap; not implemented |
| **N/A** | Out of scope for v1 |

---

## Summary

| Area | Shipped | Partial | Planned |
|------|---------|---------|---------|
| Tournament lifecycle | Create, weeks, pods, standings | Edit tournament sheet | — |
| Players | CRUD, detail, stats | — | Import/export |
| Achievements | CRUD, always-on, random roll | Edit, icons, templates | v2 catalog (see [AchievementSpec.md](../specs/AchievementSpec.md)) |
| Stats | Weekly, standings, charts, players | Chart VoiceOver | Export |
| Settings | About, version, theme | Support + privacy links in-app | Preferences |
| Persistence | SwiftData local | — | iCloud sync |
| CI / quality | GHA lint + unit; nightly UI | Snapshot refs in CI | Xcode Cloud |
| Analytics | AppLog + Firebase scaffold | Real Firebase project | — |
| Accessibility | Component labels, UI audits | Manual VO sign-off | WCAG Pass |
| iPad & landscape layout | Universal binary runs | Max-width, landscape sticky bar | Split view |
| Localization | English | — | Additional locales |
| App Store | Listing copy, Pages HTML | TestFlight | Public release |

---

## Core features

### Tournaments

| Feature | Status | Code / docs |
|---------|--------|-------------|
| List ongoing / completed | Shipped | `TournamentsView` |
| Create tournament | Shipped | `NewTournamentView` |
| Tournament detail (pods, attendance, standings tabs) | Shipped | `TournamentDetailView` |
| Weekly attendance | Shipped | `AttendanceView` |
| Pod scoring (placement + achievements) | Shipped | `LeagueEngine` |
| Undo last pod | Shipped | `LeagueEngine.undoLastPod` |
| Edit last round | Shipped | `EditLastRoundView` |
| Weekly standings sheet | Shipped | In tournament detail flow |
| Final tournament standings | Shipped | `TournamentStandingsView` |
| Edit tournament metadata | Shipped | `EditTournamentView` |
| Delete tournament | Shipped | `TournamentsViewModel` |

### Players & achievements

| Feature | Status | Notes |
|---------|--------|-------|
| Global player pool | Shipped | Shared across tournaments |
| Player detail + history | Shipped | `PlayerDetailView` |
| Achievement catalog | Shipped | `AchievementsView` |
| Add achievement | Shipped | `NewAchievementView` |
| Edit achievement (full) | Planned | [achievement-improvements-plan.md](achievement-improvements-plan.md) Sprint A2 |
| Achievement icons (SF Symbols) | Planned | [AchievementSpec.md](../specs/AchievementSpec.md) §4 |
| Achievement templates | Planned | [achievement-improvements-plan.md](achievement-improvements-plan.md) Sprint A2 |
| Points tiers + balance summary | Planned | [achievement-improvements-plan.md](achievement-improvements-plan.md) Sprint A2–A3 |
| Exclusivity (one per pod / per week) | Planned | [achievement-improvements-plan.md](achievement-improvements-plan.md) Sprint A4 |
| Default "First Blood" seed | Shipped | On first launch |

### Stats

| Feature | Status | Notes |
|---------|--------|-------|
| Weekly / standings / players segments | Shipped | `StatsView` |
| Bar, line, pie charts | Partial | Needs richer a11y |
| Empty state | Shipped | `EmptyStateView` |

### Infrastructure

| Feature | Status | Docs |
|---------|--------|------|
| GitHub Actions CI | Shipped | [infrastructure.md](infrastructure.md) |
| Nightly UI tests | Shipped | `.github/workflows/nightly-ui.yml` |
| SwiftLint | Shipped | `.swiftlint.yml` |
| Firebase Analytics / Crashlytics | Partial | Needs production plist |
| GitHub Pages | Partial | Enable in repo settings |
| WCAG tracker | Shipped | [accessibility/wcag-2.1-aa/](../accessibility/wcag-2.1-aa/) |

### Platform & layout

| Feature | Status | Notes |
|---------|--------|-------|
| Universal iPhone + iPad binary | Shipped | Same UI; no split view |
| Landscape — menu section pickers | Shipped | Stats, tournament detail |
| Landscape — pods sticky bar | Partial | Stacked layout in compact height — [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) |
| iPad content max-width | Partial | `adaptiveContentWidth()` on core tab screens |
| Onboarding iPad portrait layout | Shipped | Wide layout when `horizontalSizeClass == .regular` |
| First-attendance coach mark | Shipped | One-time tip on tournament detail Attendance tab |
| Generate-pods coach mark | Shipped | One-time tip on tournament detail Pods tab |
| Share standings (week + final) | Shipped | `StandingsShareFormatter` + ShareLink on sheets |
| Sample league deep-link | Shipped | Onboarding load opens tournament on Attendance |
| iPad-native NavigationSplitView | Planned | Post–1.0 |

### Planned (post–1.0)

| Feature | Notes |
|---------|-------|
| iCloud sync | [ios-roadmap.md](ios-roadmap.md) |
| Player / data export | JSON or share sheet |
| Localization | German, Spanish, etc. |
| iPad split-view / sidebar | [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) Phase C |
| Widgets / Shortcuts | Quick standings glance |

---

## Test coverage snapshot

See [test-coverage.md](test-coverage.md) — all Models, Engines, and ViewModels have unit tests; UI flows cover create tournament, weekly round, and completion.
