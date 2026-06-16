# Scoring specification

Normative rules for league scoring. User-facing summary: [docs/scoring-rules.md](../docs/scoring-rules.md).

---

## 1. Placement points

For a four-player pod, placement `p` ∈ {1,2,3,4} awards:

| p | Points |
|---|--------|
| 1 | 4 |
| 2 | 3 |
| 3 | 2 |
| 4 | 1 |

Any other placement → 0 points. Defined in `AppConstants.Scoring.placementPoints(forPlace:)`.

---

## 2. Achievement points

When player `P` earns achievement `A` in a pod:

- Add `A.points` to `P`'s weekly total for the active tournament.
- Add `A.points` to `P.achievementPoints` (lifetime).
- Multiple players may earn the same achievement in one pod.

If `achievementsOnThisWeek` is false at attendance, achievement UI is hidden and no achievement points are awarded.

---

## 3. Pod generation

| Round | Algorithm |
|-------|-----------|
| 1 | Random shuffle of present players, groups of 4 |
| 2+ | Group by weekly points (performance-based — see `LeagueEngine`) |

Remainder players (< 4) are handled per engine logic (document in code comments when changed).

---

## 4. Weekly progression

1. Save all pods for current round.
2. If round < 3 → increment round, generate new pods.
3. If round = 3 → show weekly standings; on continue → increment week or complete tournament.

---

## 5. Tournament completion

When `currentWeek > totalWeeks`:

- Set `status = completed`, `endDate = now`.
- Present tournament standings.
- Increment `tournamentsPlayed` for participants.

---

## 6. Undo / edit

- **Undo last pod:** Reverse scoring from most recent pod in `podHistory`.
- **Edit last round:** Replace last pod placements/achievements and reapply scoring.

Both must leave data consistent — covered by `EditRoundSystemTests`, `ScoringIntegrationTests`.

---

## 7. Wins

A **win** is awarded to the player with placement 1 in a saved pod (`Player.wins` incremented).

---

## 8. Change control

Scoring changes require:

- `AppConstants.Scoring` update
- `LeagueEngine` update
- Test updates
- This spec + `docs/scoring-rules.md` update
