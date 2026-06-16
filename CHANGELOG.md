# Changelog

All notable changes to League Keeper are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added

- GitHub Actions CI (SwiftLint, unit tests, coverage summary)
- Nightly UI and accessibility test workflow
- Firebase Analytics + Crashlytics scaffold (`AppLog`, allowlisted events)
- WCAG 2.1 AA compliance tracker (`accessibility/wcag-2.1-aa/`)
- Extensive documentation (`docs/`, `specs/`)
- GitHub Pages static site (privacy, support, accessibility)
- SwiftLint configuration and CONTRIBUTING guide
- `WCAGContrastTests` for semantic color tokens

### Changed

- Orphaned UI tests moved into `BudgetLeagueTrackerUITests/Screens/`
- Privacy policy updated for optional Firebase in Release builds
- README expanded with documentation index and CI section

---

## [1.0.0] — (planned)

### Added

- Multi-week tournament lifecycle (attendance, pods, standings)
- Player and achievement management
- Stats tab with charts
- Settings (version, author credit)
- Local SwiftData persistence

---

[Unreleased]: https://github.com/jacobrozell/League-Keeper-iOS/compare/main...HEAD
[1.0.0]: https://github.com/jacobrozell/League-Keeper-iOS/releases/tag/v1.0.0
