# Infrastructure

Production-quality tooling for League Keeper, modeled after [Dart Buddy](https://github.com/jacobrozell/Dart-Buddy).

## CI/CD

| Workflow | Trigger | What it runs |
|----------|---------|--------------|
| [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) | Push/PR to `main` | SwiftLint → build-for-testing → unit tests + coverage summary |
| [`.github/workflows/nightly-ui.yml`](../.github/workflows/nightly-ui.yml) | Daily 08:00 UTC + manual | UI tests + accessibility audits |

CI uses the `BudgetLeagueTrackerCI` scheme. Snapshot suites are skipped until `__Snapshots__` references are committed (see [testing.md](testing.md)).

### Local CI commands

```bash
xcodegen generate
cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist
swiftlint lint
Scripts/ci/run-tests.sh "platform=iOS Simulator,name=iPhone 17"
```

## Analytics & crash reporting

- **AppLogger** (`BudgetLeagueTracker/Support/Logging/`) — unified logging to console, Firebase Analytics, and Crashlytics
- **Allowlisted events only** — see `FirebaseAnalyticsEventMapping.swift` and unit tests
- **Release-only collection** — Debug builds and UI tests disable Firebase via feature flags
- **Setup:** Create a Firebase project, download `GoogleService-Info.plist` into `Resources/` (never commit — use `.example` in git)

## GitHub Pages

Static legal/support site lives in `docs/*.html` (alongside markdown docs).

1. Open [repository Settings → Pages](https://github.com/jacobrozell/League-Keeper-iOS/settings/pages)
2. Source: **Deploy from branch**
3. Branch: `main`, folder: `/docs`
4. URLs:
   - Home: `https://jacobrozell.github.io/League-Keeper-iOS/`
   - Privacy: `https://jacobrozell.github.io/League-Keeper-iOS/privacy.html`
   - Support: `https://jacobrozell.github.io/League-Keeper-iOS/support.html`

Use these URLs in App Store Connect.

## Code quality

- **SwiftLint** — `.swiftlint.yml` gates CI on `print()` in app code
- **Git hooks** — `Scripts/install-git-hooks.sh` blocks Firebase secret commits

## Accessibility

- Labels/identifiers on components and views
- `AccessibilityAuditTests` in UI test target (runs nightly)
- **WCAG 2.1 AA tracker:** [accessibility/wcag-2.1-aa/SUMMARY.md](accessibility/wcag-2.1-aa/SUMMARY.md)
- Manual sign-off checklist: [accessibility/Manual_todo.md](accessibility/Manual_todo.md)
- Public statement: [docs/accessibility.html](accessibility.html)

## Documentation

Full index: [docs/README.md](docs/README.md)

| Area | Entry point |
|------|-------------|
| Specs | [specs/README.md](../specs/README.md) |
| WCAG | [accessibility/wcag-2.1-aa/](../accessibility/wcag-2.1-aa/) |
| Release | [release/README.md](release/README.md) |
| GitHub Pages | [github-pages.md](github-pages.md) |

## Roadmap (Dart Buddy parity)

| Item | Status |
|------|--------|
| GitHub Actions CI | Done |
| Nightly UI matrix | Done |
| Firebase Analytics + Crashlytics | Done (needs real plist) |
| GitHub Pages | Done (enable in settings) |
| SwiftLint + CONTRIBUTING | Done |
| Extensive docs + specs | Done |
| WCAG tracker | Done |
| WCAG manual sign-off | Pending |
| Xcode Cloud / TestFlight | Planned — [release/testflight.md](release/testflight.md) |
| Marketing screenshots | Planned |
