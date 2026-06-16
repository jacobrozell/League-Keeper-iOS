# Contributing to League Keeper

Thanks for helping improve League Keeper. This project follows patterns established in [Dart Buddy](https://github.com/jacobrozell/Dart-Buddy).

## Prerequisites

- Xcode 16+ (iOS 18 deployment target)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- [SwiftLint](https://github.com/realm/SwiftLint): `brew install swiftlint`

## Setup

```bash
xcodegen generate
cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist  # CI uses placeholder
open BudgetLeagueTracker.xcodeproj
```

Optional git hooks (blocks committing real Firebase plists):

```bash
Scripts/install-git-hooks.sh
```

## Code style

- Swift 6 with strict concurrency
- Use `AppLog.shared` instead of `print()` in app code
- Centralize constants in `AppConstants.swift`
- Add `accessibilityLabel` / `accessibilityIdentifier` on interactive UI
- Run `swiftlint` before pushing

## Testing

```bash
# Unit tests (CI scheme; skips snapshot suites until references are committed)
Scripts/ci/run-tests.sh "platform=iOS Simulator,name=iPhone 17"

# UI + accessibility (nightly workflow)
xcodebuild test -scheme BudgetLeagueTrackerUI -destination "platform=iOS Simulator,name=iPhone 17"
```

See [docs/testing.md](docs/testing.md) for the full strategy.

## Pull requests

1. Branch from `main`
2. Ensure CI passes (lint + unit tests)
3. Update docs if behavior or infrastructure changes
4. Keep PRs focused — one feature or fix per PR when possible

## Analytics events

New Firebase Analytics events must be added to the allowlist in `FirebaseAnalyticsEventMapping.swift` with unit tests in `BudgetLeagueTrackerTests/Support/`. Never log player names or freeform user text.

## Accessibility

Before marking a screen complete for release, update its row in [`accessibility/wcag-2.1-aa/screens/`](accessibility/wcag-2.1-aa/screens/) and rollup in [`SUMMARY.md`](accessibility/wcag-2.1-aa/SUMMARY.md). Run manual checks from [`accessibility/Manual_todo.md`](accessibility/Manual_todo.md) when changing navigation or forms.
