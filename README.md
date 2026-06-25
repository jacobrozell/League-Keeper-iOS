# League Keeper (Budget League Tracker)

League Keeper helps you run and track recurring game leagues: create tournaments, record attendance and table seating, score placement and achievements, and view weekly and final standings. Budget Commander (MTG) is available as a one-tap preset for card-game hosts.

**Status:** Pre–TestFlight · v1.0.0 (1) · **Branch:** `main` · [Release todo](docs/release/todo.md)

- **Platform:** iOS 18+, Swift 6, SwiftUI, SwiftData
- **Project:** XcodeGen (`project.yml`) → `BudgetLeagueTracker.xcodeproj`
- **Repo:** [github.com/jacobrozell/League-Keeper-iOS](https://github.com/jacobrozell/League-Keeper-iOS)

---

## Documentation

**Start here:** [docs/README.md](docs/README.md) — full documentation index.

### Getting started

| Document | Description |
|----------|-------------|
| [docs/development.md](docs/development.md) | Build, run, test, where to change things |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Code style, PR expectations, a11y rules |
| [docs/domain-glossary.md](docs/domain-glossary.md) | Pods, rounds, placement points, etc. |

### Architecture & domain

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | Layers, data flow, project structure |
| [specs/ArchitectureSpec.md](specs/ArchitectureSpec.md) | Normative architecture spec |
| [docs/data-model.md](docs/data-model.md) | SwiftData entities |
| [docs/scoring-rules.md](docs/scoring-rules.md) | How points are calculated |
| [docs/navigation.md](docs/navigation.md) | Tabs, screens, sheets |
| [docs/user-flows.md](docs/user-flows.md) | User journeys |
| [docs/design-system.md](docs/design-system.md) | Components and colors |

### Quality & infrastructure

| Document | Description |
|----------|-------------|
| [docs/testing.md](docs/testing.md) | Test strategy and how to run tests |
| [docs/test-coverage.md](docs/test-coverage.md) | Source → test mapping |
| [docs/infrastructure.md](docs/infrastructure.md) | CI, Firebase, GitHub Pages, SwiftLint |
| [docs/logging-analytics.md](docs/logging-analytics.md) | AppLog and allowlisted events |
| [specs/TestPlanSpec.md](specs/TestPlanSpec.md) | Test plan spec |

### Accessibility

| Document | Description |
|----------|-------------|
| [accessibility/wcag-2.1-aa/README.md](accessibility/wcag-2.1-aa/README.md) | WCAG 2.1 AA tracker |
| [accessibility/Manual_todo.md](accessibility/Manual_todo.md) | Manual VoiceOver checklist |
| [specs/AccessibilitySpec.md](specs/AccessibilitySpec.md) | Accessibility requirements |

### Release & App Store

| Document | Description |
|----------|-------------|
| [docs/release/README.md](docs/release/README.md) | Release train overview |
| [docs/release/testflight.md](docs/release/testflight.md) | TestFlight guide |
| [docs/release/1.0-ship-checklist.md](docs/release/1.0-ship-checklist.md) | Pre-submission checklist |
| [docs/ios-roadmap.md](docs/ios-roadmap.md) | Product roadmap |
| [docs/feature-inventory.md](docs/feature-inventory.md) | Shipped vs planned features |
| [docs/app-store-listing.md](docs/app-store-listing.md) | App Store copy |
| [specs/AppStoreConnectSpec.md](specs/AppStoreConnectSpec.md) | Store metadata spec |

### Legal (hosted)

| Document | Description |
|----------|-------------|
| [docs/github-pages.md](docs/github-pages.md) | Enable GitHub Pages |
| [docs/privacy-policy.md](docs/privacy-policy.md) | Privacy policy source |
| [docs/support.md](docs/support.md) | Support page source |

### Specifications

All specs: [specs/README.md](specs/README.md) · Governance: [specs/SpecGovernance.md](specs/SpecGovernance.md)

---

## Project structure

```
BudgetLeagueTracker/     App source (Models, Engine, ViewModels, Views, Components)
BudgetLeagueTrackerTests/  Unit, integration, snapshot tests
BudgetLeagueTrackerUITests/ UI and accessibility tests
docs/                    Guides and hosted HTML (GitHub Pages)
specs/                   Normative specifications
accessibility/           WCAG tracker and manual checklists
.github/workflows/       CI and nightly UI
Scripts/ci/              CI helper scripts
```

---

## CI

| Workflow | Trigger | Runs |
|----------|---------|------|
| [ci.yml](.github/workflows/ci.yml) | Push / PR to `main` | SwiftLint, build, unit tests, coverage |
| [nightly-ui.yml](.github/workflows/nightly-ui.yml) | Daily + manual | UI + accessibility tests |

```bash
xcodegen generate
swiftlint lint BudgetLeagueTracker
Scripts/ci/run-tests.sh "platform=iOS Simulator,name=iPhone 17"
```

---

## Building and running

1. `brew install xcodegen` (if needed)
2. `xcodegen generate`
3. `cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist`
4. Open `BudgetLeagueTracker.xcodeproj` → Run (⌘R)

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

---

## License

Copyright © 2025 Jacob Rozell. All rights reserved.
