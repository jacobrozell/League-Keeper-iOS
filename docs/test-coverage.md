# Test Coverage — Budget League Tracker

This document summarizes where the project stands with test coverage: what’s covered, how it’s covered, and what’s not. Use it to see current coverage at a glance and to update after running code coverage in Xcode.

**Last structural update:** February 2026 (source/test mapping).  
**Numeric coverage:** Run tests with code coverage in Xcode and fill in the “Numeric coverage” section below (see [How to get numeric coverage](#how-to-get-numeric-coverage)).

---

## Summary by layer

| Layer | Source files | Unit / integration tests | Snapshot tests | UI tests | Gaps |
|-------|--------------|---------------------------|----------------|----------|------|
| **App entry** | 1 | — | — | exercised by launch | BudgetLeagueTrackerApp — no dedicated unit tests |
| **Models** | 7 | ✅ All 7 | — | — | None |
| **Engine** | 3 | ✅ All 3 | — | — | None |
| **ViewModels** | 15 | ✅ All 15 | — | — | None |
| **Views** | 17 | routing via NavigationStateTests | ✅ All 17 (ScreenSnapshotTests) | ✅ 2 screens (Tournaments, Achievements) + flows | ContentView — routing unit-tested; view exercised by UI |
| **Components** | 18 | ✅ behavior (ComponentBehaviorTests) | ✅ many (ComponentSnapshotTests, ChartsSnapshotTests) | — | Some components only via snapshots |
| **Constants** | 1 | ✅ AppConstantsTests | — | — | None |

**Overall:** Unit/integration and snapshot coverage is strong for Models, Engine, ViewModels, and main Views. UI tests cover key flows and a subset of screens. Gaps are mainly app entry and optional extra UI/screen coverage.

---

## Source → test mapping

### App & navigation

| Source | Unit / integration | Snapshot | UI | Notes |
|--------|--------------------|----------|-----|------|
| `BudgetLeagueTrackerApp.swift` | — | — | Launch | No dedicated unit tests. |
| `ContentView.swift` | NavigationStateTests (routing) | — | All flows | View exercised by UI tests. |

### Models (BudgetLeagueTracker/Models/)

| Source | Test file | Type |
|--------|-----------|------|
| Achievement.swift | AchievementTests.swift | Unit |
| ChartData.swift | ChartDataTests.swift | Unit |
| GameResult.swift | GameResultTests.swift | Unit |
| LeagueState.swift | LeagueStateTests.swift | Unit |
| Player.swift | PlayerTests.swift | Unit |
| Screen.swift | ScreenTests.swift | Unit |
| Tournament.swift | TournamentTests.swift | Unit |

### Engine (BudgetLeagueTracker/Engine/)

| Source | Test file | Type |
|--------|-----------|------|
| AchievementStatsEngine.swift | AchievementStatsEngineTests.swift | Unit |
| LeagueEngine.swift | LeagueEngineTests.swift | Unit |
| StatsEngine.swift | StatsEngineTests.swift | Unit |

### ViewModels (BudgetLeagueTracker/ViewModels/)

| Source | Test file | Type |
|--------|-----------|------|
| AchievementsViewModel.swift | AchievementsViewModelTests.swift (includes NewAchievementViewModelTests) | Unit |
| AddPlayersViewModel.swift | AddPlayersViewModelTests.swift | Unit |
| AttendanceViewModel.swift | AttendanceViewModelTests.swift | Unit |
| ConfirmNewTournamentViewModel.swift | ConfirmNewTournamentViewModelTests.swift | Unit |
| DashboardViewModel.swift | DashboardViewModelTests.swift | Unit |
| EditLastRoundViewModel.swift | EditLastRoundViewModelTests.swift | Unit |
| NewAchievementViewModel.swift | AchievementsViewModelTests.swift (NewAchievementViewModelTests) | Unit |
| NewTournamentViewModel.swift | NewTournamentViewModelTests.swift | Unit |
| PlayerDetailViewModel.swift | PlayerDetailViewModelTests.swift | Unit |
| PlayersViewModel.swift | PlayersViewModelTests.swift | Unit |
| PodsViewModel.swift | PodsViewModelTests.swift | Unit |
| StatsViewModel.swift | StatsViewModelTests.swift | Unit |
| TournamentDetailViewModel.swift | TournamentDetailViewModelTests.swift | Unit |
| TournamentStandingsViewModel.swift | TournamentStandingsViewModelTests.swift | Unit |
| TournamentsViewModel.swift | TournamentsViewModelTests.swift | Unit |

### Views (BudgetLeagueTracker/Views/)

| Source | Unit / integration | Snapshot (ScreenSnapshotTests) | UI |
|--------|--------------------|---------------------------------|-----|
| AchievementsView.swift | — | ✅ AchievementsViewSnapshots | AchievementsScreenTests |
| AddPlayersView.swift | — | ✅ AddPlayersViewSnapshots | Via CreateTournament flow |
| AttendanceView.swift | — | ✅ AttendanceViewSnapshots | Via flows |
| ConfirmNewTournamentView.swift | — | ✅ ConfirmNewTournamentViewSnapshots | Via flows |
| DashboardView.swift | — | ✅ DashboardViewSnapshots | DashboardScreenTests (root) |
| EditLastRoundView.swift | — | ✅ EditLastRoundViewSnapshots | Via WeeklyRoundFlowTests |
| EditTournamentView.swift | — | ✅ EditTournamentViewSnapshots | — |
| NewAchievementView.swift | — | ✅ NewAchievementViewSnapshots | — |
| NewTournamentView.swift | — | ✅ NewTournamentViewSnapshots | CreateTournamentFlowTests |
| PlayerDetailView.swift | — | ✅ PlayerDetailViewSnapshots | — |
| PlayersView.swift | — | ✅ PlayersViewSnapshots | PlayersScreenTests (root) |
| PodsView.swift | — | ✅ PodsViewSnapshots | — |
| SettingsView.swift | — | ✅ SettingsViewSnapshots | SettingsScreenTests (root) |
| StatsView.swift | — | ✅ StatsViewSnapshots | StatsScreenTests (root) |
| TournamentDetailView.swift | — | ✅ TournamentDetailViewSnapshots | Via flows |
| TournamentStandingsView.swift | — | ✅ TournamentStandingsViewSnapshots | TournamentCompletionFlowTests |
| TournamentsView.swift | — | ✅ TournamentsViewSnapshots | TournamentsScreenTests |

### Components (BudgetLeagueTracker/Components/)

| Source | Behavior tests | Snapshot tests |
|--------|----------------|----------------|
| AchievementCheckItem.swift | ComponentBehaviorTests | ComponentSnapshotTests |
| AchievementListRow.swift | — | ComponentSnapshotTests |
| AchievementStatsCard.swift | — | ChartsSnapshotTests (charts) |
| BarChartView.swift | — | ChartsSnapshotTests |
| DestructiveActionButton.swift | ComponentBehaviorTests | ComponentSnapshotTests |
| EmptyStateView.swift | — | ComponentSnapshotTests |
| HintText.swift | — | ComponentSnapshotTests |
| LabeledStepper.swift | — | ComponentSnapshotTests |
| LabeledToggle.swift | — | ComponentSnapshotTests |
| LineChartView.swift | — | ChartsSnapshotTests |
| ModalActionBar.swift | — | ComponentSnapshotTests |
| PieChartView.swift | — | ChartsSnapshotTests |
| PlacementPicker.swift | ComponentBehaviorTests | ComponentSnapshotTests |
| PlayerRow.swift | — | — |
| PrimaryActionButton.swift | ComponentBehaviorTests | ComponentSnapshotTests |
| SecondaryButton.swift | ComponentBehaviorTests | ComponentSnapshotTests |
| StandingsRow.swift | — | ComponentSnapshotTests |
| TournamentCell.swift | — | ComponentSnapshotTests |

### Constants

| Source | Test file | Type |
|--------|-----------|------|
| AppConstants.swift | AppConstantsTests.swift | Unit |

### Integration tests (cross-cutting)

| Test file | Covers |
|-----------|--------|
| EditRoundSystemTests.swift | Edit-round flow, engine + ViewModel interaction |
| ScoringIntegrationTests.swift | Scoring, engine + state |
| TournamentLifecycleTests.swift | Tournament lifecycle, engine + state |

### UI tests (BudgetLeagueTrackerUITests)

| Test file | Type | Covers |
|-----------|------|--------|
| CreateTournamentFlowTests.swift | Flow | New tournament → Add players |
| TournamentCompletionFlowTests.swift | Flow | Complete tournament, view standings |
| WeeklyRoundFlowTests.swift | Flow | Weekly round, edit last round |
| TournamentsScreenTests.swift | Screen | Tournaments tab, empty state, navigation, dark/landscape |
| AchievementsScreenTests.swift | Screen | Achievements tab |
| AccessibilityAuditTests.swift | Accessibility | Basic audit |
| (root) DashboardScreenTests, PlayersScreenTests, SettingsScreenTests, StatsScreenTests | Screen | Dashboard, Players, Settings, Stats (if in UITest target) |

---

## Gaps and “not covered”

- **BudgetLeagueTrackerApp** — App entry point; no unit tests. Exercised by UI test launch.
- **ContentView** — Routing is unit-tested via `NavigationStateTests`; the view body is only exercised by UI tests.
- **PlayerRow** — No dedicated snapshot or behavior test (may appear in screen snapshots).
- **EditTournamentView** — Snapshot only; no dedicated UI flow test.
- **Full E2E** — Beyond existing UI flows; additional edge cases as needed.

---

## Numeric coverage (fill in after running Xcode)

To get line/region percentages:

1. In Xcode: **Edit Scheme → Test → Options → Code Coverage: On**. Then **Product → Test (⌘U)**.
2. Open **Report navigator** (last test run) → **Coverage** tab.
3. Or from CLI:  
   `xcodebuild test -scheme BudgetLeagueTracker -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES -resultBundlePath ./CoverageResults.xcresult`  
   Then open `CoverageResults.xcresult` in Xcode and use the Coverage tab.

Record results here when you run it:

| Area | Line coverage | Region coverage | Date |
|------|----------------|-----------------|------|
| Overall | _% | _% | |
| Models | _% | _% | |
| Engine | _% | _% | |
| ViewModels | _% | _% | |
| Views | _% | _% | |
| Components | _% | _% | |

---

## How to get numeric coverage

- **Xcode:** Edit Scheme → Test → Options → check **Code Coverage** → run tests (⌘U). In Report navigator, select the latest run and open the **Coverage** tab for per-file line/region coverage.
- **CI/script:** Use  
  `xcodebuild test -scheme BudgetLeagueTracker -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES -resultBundlePath ./CoverageResults.xcresult`  
  then open the generated `.xcresult` in Xcode for the Coverage tab, or use `xcrun xccov` to parse coverage from the result bundle.

See also [testing.md](testing.md) for how to run tests and maintain snapshots.
