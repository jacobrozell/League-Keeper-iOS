# Scoring & stats correctness port plan

Port of fixes from draft PR [#1](https://github.com/jacobrozell/League-Keeper-iOS/pull/1) (`claude/loving-sagan-dee4j9`) onto current `main`. The branch is **not merged**; this document tracks what we port and how.

## Problems (fixed in this port)

1. **Multi-pod `podId`** — `finalizeRound` now reads `currentRoundPodsPlayerIds` and assigns one UUID per table.
2. **Edit round pod identity** — `applyEditedRound` preserves each player's existing `podId`.
3. **Unstable tie order** — `StandingsRanking` provides deterministic tiebreaks (points → name → id).
4. **Chart legend** — `BarChartView` builds the color scale from actual series names in data order.

## Already on main (not re-ported)

- `PodSnapshot.week` / `.round` (required, backward-compatible decode)
- Undo and edit target snapshot week/round after advancing
- `currentRoundPodsPlayerIds` stored when seating (`TournamentDetailViewModel.seatPlayers`)

## Port strategy

| Item | Approach |
|------|----------|
| Per-pod IDs | Read `currentRoundPodsPlayerIds` in `finalizeRound` before clearing transient state; map one UUID per pod group |
| Edit preserve IDs | In `applyEditedRound`, capture existing `podId` per player before delete; reuse on insert |
| Tiebreaks | New `StandingsRanking` helper; use everywhere points-sorted lists or winner are computed |
| Chart legend | Build `chartForegroundStyleScale(domain:range:)` from actual series in data order |
| Tests | `PodIntegrityTests` (integration) + deterministic tie test in `StatsEngineTests` |
| Deprecated `PodsViewModel` | Set `currentRoundPodsPlayerIds` when generating pods (legacy path) |

## Files to touch

- `BudgetLeagueTracker/Support/StandingsRanking.swift` (new)
- `BudgetLeagueTracker/Engine/LeagueEngine.swift`
- `BudgetLeagueTracker/Engine/StatsEngine.swift`
- `BudgetLeagueTracker/Components/Charts/BarChartView.swift`
- `BudgetLeagueTracker/ViewModels/TournamentDetailViewModel.swift`
- `BudgetLeagueTracker/ViewModels/TournamentStandingsViewModel.swift`
- `BudgetLeagueTracker/ViewModels/TournamentsViewModel.swift`
- `BudgetLeagueTracker/ViewModels/StatsViewModel.swift`
- `BudgetLeagueTracker/ViewModels/PodsViewModel.swift`
- `BudgetLeagueTrackerTests/Integration/PodIntegrityTests.swift` (new)
- `BudgetLeagueTrackerTests/Engine/StatsEngineTests.swift`
- `League Keeper.xcodeproj/project.pbxproj`

## Verification

- [x] App target builds (`xcodebuild build` succeeded)
- [ ] Unit + integration tests pass locally (Xcode build-system crash blocked `build-for-testing` in this session — re-run in Xcode)
- [ ] Close draft PR #1 after merge (manual)

## Status

- [x] Plan written
- [x] Implementation
- [x] Tests added (`PodIntegrityTests`, `StandingsRankingTests`, `StatsEngineTests` tie case)
- [x] App build green
- [ ] Full test suite green (re-run: `PodIntegrityTests`, `StandingsRankingTests`, `StatsEngineTests/tournamentSummary`)
- [ ] PR #1 superseded (close draft manually)
