# Scoring rules

How League Keeper calculates points. **Normative spec:** [specs/ScoringSpec.md](../specs/ScoringSpec.md). **Code:** `AppConstants.Scoring`, `LeagueEngine`.

---

## Placement points

Awarded by finish position in a four-player pod:

| Place | Points |
|-------|--------|
| 1st | 4 |
| 2nd | 3 |
| 3rd | 2 |
| 4th | 1 |

Implemented in `AppConstants.Scoring.placementPoints(forPlace:)`.

---

## Achievement points

Each achievement has a **name** and **point value**. When a player earns an achievement in a pod:

- Points are added to that player's **weekly total** for the tournament.
- Points are added to the player's **lifetime achievement points**.
- If the achievement is checked for multiple players in one pod, each checked player receives the full value.

**Always-on achievements** are included in the active set every week. **Random achievements** are rolled when the week starts (count = `tournament.randomAchievementsPerWeek`).

Default seeded achievement: **First Blood** (1 point, not always-on).

---

## Weekly flow

1. **Attendance** — Mark present players; optionally disable achievements for the week.
2. **Round 1 pods** — Random grouping among present players (groups of 4).
3. **Rounds 2–3** — Pods grouped by current **weekly points** (snake / performance-based — see `LeagueEngine`).
4. After **round 3** — Show weekly standings sheet.
5. **Next week** — Increment week, roll new random achievements, reset weekly state.

---

## Tournament completion

When the final week finishes:

- Tournament `status` → completed.
- **Tournament standings** full-screen cover shows final ranking (placement + achievement points).
- Player cumulative stats (`tournamentsPlayed`, etc.) are updated.

---

## Undo

**Undo last pod** removes the most recent pod from history and reverses its scoring effects on weekly and player totals.

**Edit last round** opens a sheet to change placements/achievements for the last saved pod.

---

## Stats tab

- **Weekly** — Current or selected week rankings.
- **Standings** — Tournament-level totals.
- **Charts** — Visual trends (placement vs achievement points).
- **Players** — Per-player cumulative performance.

---

## Changing rules

1. Update `AppConstants.Scoring` (and `League` if pod size / rounds change).
2. Update `LeagueEngine` logic.
3. Update [specs/ScoringSpec.md](../specs/ScoringSpec.md) and this doc.
4. Add/update tests in `LeagueEngineTests`, `ScoringIntegrationTests`.
