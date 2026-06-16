# Navigation specification

## 1. Tab structure

Five tabs (iOS 18 `Tab` API): Tournaments, Players, Stats, Achievements, Settings.

Tab bar visibility controlled by `NavigationState.shouldHideTabBar` during full-screen flows.

---

## 2. Screen enum

`Screen` cases in `Models/Screen.swift`:

| Case | Maps to |
|------|---------|
| `tournaments`, `dashboard` | Tournaments list |
| `newTournament`, `confirmNewTournament` | New tournament form |
| `addPlayers` | Add players flow |
| `attendance` | Weekly attendance |
| `pods` | Legacy — absorbed into tournament detail |
| `tournamentDetail` | Push navigation |
| `tournamentStandings` | Full-screen cover trigger |

Legacy cases remain for persisted state compatibility.

---

## 3. Active tournament

`LeagueState.activeTournamentId` must be set when:

- Starting a new tournament
- Opening tournament detail (via `setAsActiveTournament`)

Engine operations assume active tournament for attendance/pods.

---

## 4. Presentation rules

| UI | Presentation |
|----|--------------|
| New tournament | Replaces tournaments stack content |
| Attendance | Sheet from detail OR full-screen flow |
| Edit last round | Sheet |
| Edit tournament | Sheet from list |
| New achievement | Sheet |
| Tournament standings | Full-screen cover on completion |

---

## 5. Back navigation

- System back from `TournamentDetailView` pops navigation stack.
- Full-screen flows set `LeagueState.screen` to return to tournaments list.
- Tab selection is not persisted across launches (defaults to Tournaments).

---

## 6. Testing

- `NavigationStateTests` — screen routing logic
- UI tests — `CreateTournamentFlowTests`, `WeeklyRoundFlowTests`
- [docs/navigation.md](../docs/navigation.md) — diagrams
