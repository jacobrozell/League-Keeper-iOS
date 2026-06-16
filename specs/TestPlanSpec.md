# Test plan specification

## 1. Goals

- Confidence to refactor scoring and persistence
- Regression safety for UI flows
- Accessibility and appearance coverage
- Fast PR feedback (< 10 min unit CI)

---

## 2. Test pyramid

| Layer | Framework | Target | CI |
|-------|-----------|--------|-----|
| Unit | Swift Testing | Models, Engine, ViewModels | PR (`BudgetLeagueTrackerCI`) |
| Integration | Swift Testing | Tournament lifecycle, scoring | PR |
| Snapshot | SnapshotTesting | Components, screens | Local / future CI |
| UI | XCTest | Flows, screens, a11y | Nightly (`BudgetLeagueTrackerUI`) |
| Contrast | Swift Testing | Color tokens | PR |

---

## 3. CI schemes

### BudgetLeagueTrackerCI (PR)

- SwiftLint on `BudgetLeagueTracker/`
- Build for testing + unit tests
- Coverage artifact (`coverage-summary.txt`)
- Skips snapshot suites until refs stabilized

### BudgetLeagueTrackerUI (nightly)

- Full UI test target including `AccessibilityAuditTests`

---

## 4. Required tests for changes

| Change type | Required tests |
|-------------|----------------|
| Scoring rule | `LeagueEngineTests`, `ScoringIntegrationTests` |
| New ViewModel action | ViewModel test file |
| New screen | Snapshot + UI audit (or flow test) |
| New analytics event | `FirebaseAnalyticsEventMappingTests` |
| Accessibility fix | Update WCAG screen file + audit test if applicable |

---

## 5. Test data

- `TestHelpers.bootstrappedContext()` — in-memory SwiftData
- `TestFixtures` — players, tournaments, achievements
- UI: `--uitesting` launch arg disables Firebase

---

## 6. Coverage

- Target: high coverage on Engine + ViewModels (no hard gate yet)
- Report: `Scripts/ci/coverage-summary.sh`
- Mapping: [docs/test-coverage.md](../docs/test-coverage.md)

---

## 7. Snapshot policy

- Record on Mac with `SnapshotTestConfiguration.record = true`
- Commit `__Snapshots__/` per test folder
- Light + dark for visual components
- Exclude `__Snapshots__` from app bundle (project.yml)

---

## 8. Related

- [docs/testing.md](../docs/testing.md)
- [docs/infrastructure.md](../docs/infrastructure.md)
