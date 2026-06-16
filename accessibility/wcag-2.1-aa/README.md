# WCAG 2.1 AA compliance tracker

Living tracker for League Keeper accessibility work. Target standard: **WCAG 2.1 Level AA**.

**Manual verification:** [`../Manual_todo.md`](../Manual_todo.md)  
**Engineering backlog:** [`../accessibility_todo.md`](../accessibility_todo.md)

## How to use

1. **Roll up status** — Start at [`SUMMARY.md`](SUMMARY.md) for screen-level counts.
2. **Criterion definitions** — [`criteria.md`](criteria.md) maps WCAG success criteria to iOS checks.
3. **Per-screen work** — Edit files under [`screens/`](screens/) when you implement or verify a screen.
4. **Evidence** — Store VoiceOver notes, screenshots, and Inspector exports under [`evidence/`](evidence/).

## Status legend

| Status | Meaning |
|--------|---------|
| `Untested` | No manual verification; code may be incomplete. |
| `Partial` | Some requirements met; known gaps remain. |
| `Pass` | Verified for this screen/criterion (note date + device in Evidence). |
| `Fail` | Verified failure; fix tracked in Open work. |
| `N/A` | Criterion does not apply to this screen. |
| `Blocked` | Cannot test until dependency ships. |

## Screen inventory

| Screen ID | Swift entry (primary) | Tracker |
|-----------|----------------------|---------|
| `tournaments` | `TournamentsView` | [screens/tournaments.md](screens/tournaments.md) |
| `tournament-detail` | `TournamentDetailView` | [screens/tournament-detail.md](screens/tournament-detail.md) |
| `new-tournament` | `NewTournamentView` | [screens/new-tournament.md](screens/new-tournament.md) |
| `add-players` | `AddPlayersView` | [screens/add-players.md](screens/add-players.md) |
| `attendance` | `AttendanceView` | [screens/attendance.md](screens/attendance.md) |
| `edit-last-round` | `EditLastRoundView` | [screens/edit-last-round.md](screens/edit-last-round.md) |
| `tournament-standings` | `TournamentStandingsView` | [screens/tournament-standings.md](screens/tournament-standings.md) |
| `players` | `PlayersView` | [screens/players.md](screens/players.md) |
| `player-detail` | `PlayerDetailView` | [screens/player-detail.md](screens/player-detail.md) |
| `stats` | `StatsView` | [screens/stats.md](screens/stats.md) |
| `achievements` | `AchievementsView` | [screens/achievements.md](screens/achievements.md) |
| `new-achievement` | `NewAchievementView` | [screens/new-achievement.md](screens/new-achievement.md) |
| `edit-tournament` | `EditTournamentView` | [screens/edit-tournament.md](screens/edit-tournament.md) |
| `settings` | `SettingsView` | [screens/settings.md](screens/settings.md) |

Shared UI: [screens/_shared-components.md](screens/_shared-components.md).

## Automated coverage

| Method | Location |
|--------|----------|
| XCTest accessibility audits | `BudgetLeagueTrackerUITests/Accessibility/AccessibilityAuditTests.swift` |
| WCAG contrast math (tokens) | `BudgetLeagueTrackerTests/Accessibility/WCAGContrastTests.swift` |
| Nightly CI | `.github/workflows/nightly-ui.yml` |

## Release rule

Do not mark **Overall: Pass** in `SUMMARY.md` until every **core flow** screen is `Pass` on all **Required** criteria and manual VoiceOver + Dynamic Type (AXXXL) evidence is attached per `Manual_todo.md`.
