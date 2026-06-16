# Domain glossary

Terms used throughout League Keeper documentation, specs, and support.

---

## League & tournament

| Term | Definition |
|------|------------|
| **League** | The overall player pool and achievement catalog shared across tournaments. Persisted as global `Player` and `Achievement` records plus one `LeagueState`. |
| **Tournament** | A multi-week season with a fixed number of weeks, weekly rounds, and final standings. Only one tournament is *active* at a time. |
| **Active tournament** | The tournament referenced by `LeagueState.activeTournamentId`. Drives attendance, pods, and stats for the current season. |
| **Week** | One meeting of the league within a tournament. Each week has up to three **rounds** of pods. |
| **Round** | One set of pods played in a week (1, 2, or 3). After round 3, **weekly standings** are shown. |

---

## Gameplay

| Term | Definition |
|------|------------|
| **Pod** | A group of four players who play one game together in a round. Placements (1st–4th) are recorded per player. |
| **Placement** | Finish position in a pod: 1st, 2nd, 3rd, or 4th. |
| **Placement points** | Points from placement: 4 / 3 / 2 / 1 for 1st–4th. See [scoring-rules.md](scoring-rules.md). |
| **Achievement** | A named bonus (e.g. "First Blood") worth a fixed number of points when earned in a pod. |
| **Always-on achievement** | Counts every week it is active without being rolled randomly. |
| **Random achievement** | Rolled from the catalog each week (`randomAchievementsPerWeek` on the tournament). |
| **Achievements on this week** | User toggle during attendance: whether achievement checkboxes appear in pod scoring. |
| **Present players** | Players marked attending for the current week; only they are grouped into pods. |
| **Pod history** | Saved pods for the current week, used for undo and standings calculation. |

---

## Standings

| Term | Definition |
|------|------------|
| **Weekly points** | Sum of placement + achievement points for a player in the current week (present players only). |
| **Weekly standings** | Ranking of present players by weekly points, shown after round 3. |
| **Tournament standings** | Final ranking of all players by cumulative placement + achievement points when the tournament completes. |
| **Cumulative stats** | Lifetime player stats across tournaments: total placement points, achievement points, wins, games played. |

---

## Technical

| Term | Definition |
|------|------------|
| **LeagueState** | Singleton navigation + active tournament pointer (`currentScreen`, `activeTournamentId`). |
| **Screen** | Enum persisted in `LeagueState` for flow navigation (e.g. `.attendance`, `.newTournament`). |
| **Engine** | Stateless business logic (`LeagueEngine`, `StatsEngine`) — no SwiftUI. |
| **ViewModel** | Per-screen coordinator between Views, SwiftData, and Engine. |

---

## See also

- [scoring-rules.md](scoring-rules.md) — numeric rules
- [data-model.md](data-model.md) — persistence
- [user-flows.md](user-flows.md) — journeys
