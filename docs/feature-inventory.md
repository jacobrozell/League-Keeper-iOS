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
| Achievements | CRUD, always-on, random roll | — | — |
| Stats | Weekly, standings, charts, players | Chart VoiceOver | Export |
| Settings | About, version | Support link in-app | Preferences |
| Persistence | SwiftData local | — | iCloud sync |
| CI / quality | GHA lint + unit; nightly UI | Snapshot refs in CI | Xcode Cloud |
| Analytics | AppLog + Firebase scaffold | Real Firebase project | — |
| Accessibility | Component labels, UI audits | Manual VO sign-off | WCAG Pass |
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
| Add / edit / delete achievement | Shipped | |
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

### Planned (post–1.0)

| Feature | Notes |
|---------|-------|
| iCloud sync | [ios-roadmap.md](ios-roadmap.md) |
| Player / data export | JSON or share sheet |
| Localization | German, Spanish, etc. |
| iPad-optimized layouts | Wider stats charts |
| Widgets / Shortcuts | Quick standings glance |

---

## Test coverage snapshot

See [test-coverage.md](test-coverage.md) — all Models, Engines, and ViewModels have unit tests; UI flows cover create tournament, weekly round, and completion.
