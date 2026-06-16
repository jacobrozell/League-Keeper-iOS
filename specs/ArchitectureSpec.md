# Architecture specification

## 1. Purpose

Define the structural architecture for League Keeper so features are implemented consistently and testably.

---

## 2. Layers

| Layer | Location | Rules |
|-------|----------|-------|
| **Views** | `BudgetLeagueTracker/Views/`, `Components/` | SwiftUI only; no business logic |
| **ViewModels** | `BudgetLeagueTracker/ViewModels/` | `@Observable` / bindable; calls Engine; saves context |
| **Engine** | `BudgetLeagueTracker/Engine/` | Pure logic; no SwiftUI imports |
| **Models** | `BudgetLeagueTracker/Models/` | `@Model` SwiftData types |
| **Support** | `BudgetLeagueTracker/Support/` | Logging, feature flags, bootstrap |
| **Constants** | `BudgetLeagueTracker/Constants/` | `AppConstants` — single source for literals |

### Dependency rule

```
Views → ViewModels → Engine → Models
Views ↛ Engine (except via ViewModel)
Engine ↛ SwiftUI
```

---

## 3. Data flow

1. User action in View calls ViewModel method.
2. ViewModel reads from `ModelContext`.
3. ViewModel calls Engine for computed updates.
4. ViewModel mutates models and `save()`.
5. `@Query` / observation refreshes UI.

No separate repository layer in v1.0 — ViewModels own persistence orchestration.

---

## 4. Concurrency

- Swift 6 with `SWIFT_STRICT_CONCURRENCY: complete`.
- ViewModels are `@MainActor` where they touch UI-bound context.
- Engine types are `Sendable` where possible.

---

## 5. Project generation

- **XcodeGen** — `project.yml` is source of truth for targets, schemes, SPM.
- Generated `BudgetLeagueTracker.xcodeproj` is not committed.
- CI always runs `xcodegen generate` before build.

---

## 6. Schemes

| Scheme | Purpose |
|--------|---------|
| `BudgetLeagueTracker` | Local dev (app + all tests) |
| `BudgetLeagueTrackerCI` | PR CI (unit tests, coverage) |
| `BudgetLeagueTrackerUI` | Nightly UI + accessibility |

---

## 7. Related docs

- [docs/architecture.md](../docs/architecture.md) — narrative overview
- [NavigationSpec.md](NavigationSpec.md)
- [DataSchemaSpec.md](DataSchemaSpec.md)
