# Budget League Tracker – Development

> **See also:** [README.md](README.md) · [CONTRIBUTING.md](../CONTRIBUTING.md) · [testing.md](testing.md) · [infrastructure.md](infrastructure.md)

How to build, run, test, and where to make common changes.

## Prerequisites

- **Xcode** — 16+ (supports iOS 18 deployment target)
- **XcodeGen** — `brew install xcodegen`
- **SwiftLint** (optional locally) — `brew install swiftlint`

## First-time setup

```bash
xcodegen generate
cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist
Scripts/install-git-hooks.sh   # optional: block Firebase secret commits
```

## Build and run

1. From the project root, run `xcodegen` to generate `BudgetLeagueTracker.xcodeproj` (if you use XcodeGen).
2. Open `BudgetLeagueTracker.xcodeproj` in Xcode.
3. Select the **BudgetLeagueTracker** scheme, choose a simulator or device, and run (⌘R).

## Testing

See [testing.md](testing.md). Quick commands:

```bash
Scripts/ci/run-tests.sh "platform=iOS Simulator,name=iPhone 17"   # unit (CI)
xcodebuild test -scheme BudgetLeagueTrackerUI -destination 'platform=iOS Simulator,name=iPhone 17'  # UI
```

## Where to change things

- **Scoring rules or league limits** – Update [AppConstants](BudgetLeagueTracker/Constants/AppConstants.swift) (e.g. `League.weeksRange`, `Scoring.placementPoints`) and any logic in [LeagueEngine](BudgetLeagueTracker/Engine/LeagueEngine.swift) that uses them.

- **New or changed data shape** – Change the SwiftData models in [Models/](BudgetLeagueTracker/Models/), then update any Engine and ViewModel code that reads or writes those models (and run tests).

- **New screen or flow** – Add a ViewModel in [ViewModels/](BudgetLeagueTracker/ViewModels/), a View in [Views/](BudgetLeagueTracker/Views/), and wire navigation (and screen enum if needed) in [ContentView](BudgetLeagueTracker/ContentView.swift) and [LeagueState](BudgetLeagueTracker/Models/LeagueState.swift) / [Screen](BudgetLeagueTracker/Models/Screen.swift) as appropriate.

- **Reusable UI (buttons, rows, empty states, pickers)** – Add or edit components in [Components/](BudgetLeagueTracker/Components/); use [AppConstants](BudgetLeagueTracker/Constants/AppConstants.swift) for sizes and constants.

## Navigation

Screen state is driven by `LeagueState.currentScreen` (and `LeagueState.activeTournamentId` for the active tournament). [ContentView](BudgetLeagueTracker/ContentView.swift) uses this to decide which tab and which stack/sheet/full-screen cover to show. When adding or changing flows, update the Screen enum and ContentView’s switch logic so the correct view is shown for each screen.
