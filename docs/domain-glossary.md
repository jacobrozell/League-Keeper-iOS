# Domain glossary

Terms used throughout League Keeper documentation, specs, and support.

---

## UI vs code terminology

| Internal (code) | User-facing (UI) |
|-----------------|------------------|
| Pod | Table |
| Generate pods | Seat players |
| Pod scoring | Score round |
| onePerPod (exclusivity) | One player per table |

Code types (`PodEngine`, `PodSnapshot`, analytics events) keep internal names. User-visible strings use **table** or **round** as appropriate.

---

## League & tournament

| Term | Definition |
|------|------------|
| **League** | The overall player pool and achievement catalog shared across tournaments. Persisted as global `Player` and `Achievement` records plus one `LeagueState`. |
| **Tournament** | A multi-week season with a fixed number of weeks, weekly rounds, and final standings. Only one tournament is *active* at a time. |
| **League preset** | Template applied at tournament creation (`simpleLeague` or `budgetCommander`). Copied into stored rules; optional metadata on `Tournament`. |
| **Active tournament** | The tournament referenced by `LeagueState.activeTournamentId`. Drives attendance, table seating, and stats for the current season. |
| **Week** | One meeting of the league within a tournament. Each week has up to three **rounds** of table play. |
| **Round** | One set of tables played in a week (1, 2, or 3). After round 3, **weekly standings** are shown. |

---

## Gameplay

| Term | Definition |
|------|------------|
| **Pod** (internal) / **Table** (UI) | A group of players (default four, configurable 2–8) who play one game together in a round. Placements are recorded per player. |
| **Placement** | Finish position at a table: 1st through N (N = players per table). |
| **Placement points** | Points from placement; default scale 4 / 3 / 2 / 1 for 1st–4th. Configurable per tournament. See [scoring-rules.md](scoring-rules.md). |
| **Achievement** | A named bonus (e.g. "Table Captain") worth a fixed number of points when earned at a table. May include a description, icon, category, and exclusivity rules. |
| **Achievement template** | Pre-defined achievement used to seed the add form; grouped into **Generic** and **Card game** libraries. |
| **Points tier** | UI preset (Small / Standard / Big / Trophy) mapping to point values with placement context. |
| **Always-on achievement** | Counts every week it is active without being rolled randomly. UI label: "Every week". |
| **Random achievement** | Rolled from the catalog each week (`randomAchievementsPerWeek` on the tournament). UI label: "Random pool". |
| **Achievement exclusivity** | Who can earn: anyone (`unlimited`), one player per table (`onePerPod`), or once per week per player (`onePerWeekPerPlayer`). |
| **Achievements on this week** | User toggle during attendance: whether achievement checkboxes appear during round scoring. |
| **Present players** | Players marked attending for the current week; only they are seated at tables. |
| **Pod history** (internal) | Saved table results for the current week, used for undo and standings calculation. |

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
- [generic-league-positioning-plan.md](generic-league-positioning-plan.md) — positioning initiative
