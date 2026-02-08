# Budget League Tracker — Testing

## Overview

The app uses a layered test strategy:

- **Unit tests** — Models, engines, ViewModels (Swift Testing)
- **Integration tests** — Tournament lifecycle, edit-round flow, scoring
- **Snapshot tests** — Components and screens (Swift Snapshot Testing)
- **UI tests** — Flows, screens, accessibility (XCTest)

Data-flow tests (engine logic and ViewModels that read/write context) are prioritized.

## How to run tests

- **Xcode:** Product → Test (⌘U), or run a specific test target/suite.
- **Command line:**  
  `xcodebuild test -scheme BudgetLeagueTracker -destination 'platform=iOS Simulator,name=iPhone 17'`
- **With code coverage (command line):**  
  `xcodebuild test -scheme BudgetLeagueTracker -destination 'platform=iOS Simulator,name=iPhone 17' -enableCodeCoverage YES`  
  Then open the test result in Xcode (Report navigator → last test run) and use the Coverage tab to see line/region coverage.

## Test layout

### BudgetLeagueTrackerTests

| Folder        | Contents                                                                 |
|---------------|---------------------------------------------------------------------------|
| Constants     | AppConstantsTests                                                         |
| Engine        | LeagueEngineTests, StatsEngineTests, AchievementStatsEngineTests         |
| Models        | AchievementTests, ChartDataTests, GameResultTests, LeagueStateTests, PlayerTests, ScreenTests, TournamentTests |
| ViewModels    | AchievementsViewModelTests, AddPlayersViewModelTests, AttendanceViewModelTests, ConfirmNewTournamentViewModelTests, DashboardViewModelTests, EditLastRoundViewModelTests, NewTournamentViewModelTests, PlayerDetailViewModelTests, PlayersViewModelTests, PodsViewModelTests, StatsViewModelTests, TournamentDetailViewModelTests, TournamentStandingsViewModelTests, TournamentsViewModelTests |
| Integration   | EditRoundSystemTests, ScoringIntegrationTests, TournamentLifecycleTests   |
| Components    | ComponentBehaviorTests, ComponentSnapshotTests, ChartsSnapshotTests (+ __Snapshots__) |
| Screens       | ScreenSnapshotTests (+ __Snapshots__)                                     |
| Helpers       | TestFixtures, TestHelpers                                                 |
| (root)        | SnapshotTestConfiguration, ChartsSnapshotTests, NavigationStateTests     |

### BudgetLeagueTrackerUITests

| Folder        | Contents                                                                 |
|---------------|---------------------------------------------------------------------------|
| Flows         | CreateTournamentFlowTests, TournamentCompletionFlowTests, WeeklyRoundFlowTests |
| Screens       | AchievementsScreenTests, TournamentsScreenTests, PlayersScreenTests, StatsScreenTests, DashboardScreenTests, SettingsScreenTests |
| Accessibility | AccessibilityAuditTests                                                 |
| Helpers       | UITestHelpers                                                            |

## What’s tested

- **Models:** LeagueState, Tournament, Player, Achievement, GameResult, Screen, ChartData types (PlayerPointsData, AchievementEarnData, PlacementData, etc.), AppConstants
- **Engines:** LeagueEngine, StatsEngine, AchievementStatsEngine
- **ViewModels:** All listed above (including AddPlayers, ConfirmNewTournament, Dashboard)
- **Integration:** Tournament lifecycle, edit-round system, scoring integration
- **Components/Screens:** Snapshot and behavior tests for shared components and main screens
- **UI:** Create tournament, tournament completion, weekly round flows; tours and achievements screens; accessibility audit

## Code coverage

- **Enable in Xcode:** Edit Scheme → Test → Options → check **Code Coverage**, then run tests (⌘U). Open the Report navigator, select the latest test run, and use the Coverage tab to see line/region coverage per file.
- **CI/script:** Use `xcodebuild test ... -enableCodeCoverage YES` and parse or archive the generated `.xcresult` for coverage tracking.

## What’s left / not covered

- **ContentView** — Routing logic is unit-tested via `NavigationState`; the view itself is exercised by UI tests.
- **BudgetLeagueTrackerApp** — App entry point; no dedicated unit tests.
- **Full E2E** — Beyond existing UI flows; additional edge cases as needed.

## Dependencies

- **TestHelpers** — `bootstrappedContext()`, `contextWithTournament()`, `fetchLeagueState()`, `fetchActiveTournament()`, `fetchAll()`, etc.
- **TestFixtures** — Player, Achievement, Tournament, GameResult, LeagueState, and context-insert helpers.
- **SnapshotTestConfiguration** — Shared config for component and screen snapshot tests.

## Snapshot tests and appearance

We maintain both **light** and **dark** reference images for a subset of views (e.g. TournamentCell, SettingsView, BarChartView). This guards against regressions in dark mode when using semantic colors.

- **Dark-mode snapshots:** Use the `darkModeForSnapshot()` view modifier (from TestHelpers) and a distinct snapshot name (e.g. `named: "ScreenName_dark"`) so dark reference images are stored alongside light ones in the same `__Snapshots__/` folders.
- **New UI with custom colors:** When adding or changing UI that uses custom or semantic colors, verify it in both light and dark appearance; add dark-mode snapshot tests for critical paths.
- **Updating references:** When refreshing snapshot refs (e.g. after layout or color changes), re-record both light and dark (and landscape, if applicable) for any affected tests.
- **Landscape:** Key screens (e.g. TournamentsView) have landscape snapshot coverage (fixed size 844×390). Layout changes should be verified in both orientations when updating snapshots.

**UI tests and appearance/orientation:** We run at least one UI test in dark mode and one in landscape as part of the regression suite (see [TournamentsScreenTests](BudgetLeagueTrackerUITests/Screens/TournamentsScreenTests.swift): `testTournamentsFlowInDarkMode`, `testTournamentsFlowInLandscape`). This helps catch catastrophic failures (e.g. white text on white in dark mode, or layout/safe-area issues in landscape). Prefer making existing UI tests robust to light/dark and portrait/landscape (e.g. avoid asserting on pixel colors or exact frames that differ by mode).

## Failing tests and snapshot maintenance

- **TournamentDetailViewModel “goToAttendance”** — Fixed. The implementation presents the attendance *sheet* via `showAttendance = true` and does not set `LeagueState.screen` to `.attendance`. The test now asserts `showAttendance == true` and `activeTournamentId` is set.
- **Snapshot tests (Component Snapshot Tests, Screen Snapshot Tests)** — These compare rendered views to stored PNGs in `__Snapshots__/`. They can fail when the simulator, OS version, or rendering changes (fonts, layout, etc.). To refresh reference images: set `SnapshotTestConfiguration.record = true` in [SnapshotTestConfiguration.swift](BudgetLeagueTrackerTests/SnapshotTestConfiguration.swift), run the snapshot tests (they will write new images), then set `record = false` again and commit the updated `__Snapshots__/` files.
