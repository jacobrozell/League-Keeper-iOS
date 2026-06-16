# Data schema specification

## 1. Persistence technology

- **SwiftData** with `@Model` macro types.
- Single `ModelContainer` registered in `BudgetLeagueTrackerApp`.
- Schema types: `Player`, `Achievement`, `LeagueState`, `Tournament`, `GameResult`.

---

## 2. Invariants

| Rule | Enforcement |
|------|-------------|
| Exactly one `LeagueState` | Bootstrap + `LeagueEngine.validateAndSanitizeState` |
| At most one active tournament | `LeagueState.activeTournamentId` |
| Pod size = 4 | `AppConstants.League.podSize` |
| Rounds per week = 3 | `AppConstants.League.roundsPerWeek` |
| Placement 1–4 only | `LeagueEngine` + UI `PlacementPicker` |
| Weeks in 1…99 | `AppConstants.League.weeksRange` |

---

## 3. Entity summaries

See [docs/data-model.md](../docs/data-model.md) for field-level documentation.

### LeagueState

- `screen: Screen` — navigation
- `activeTournamentId: UUID?` — current season

### Tournament

Holds both **metadata** (name, weeks, dates, status) and **transient weekly state** (present players, weekly points, pod history, active achievements).

### Player

Global league participant; cumulative stats updated on pod save.

### Achievement

Global catalog entry; referenced by ID in tournament weekly state.

v1 fields: `name`, `points`, `alwaysOn`.  
v2 extensions (icons, description, category, exclusivity): [AchievementSpec.md](AchievementSpec.md).

### GameResult

Historical match record for stats and player detail.

---

## 4. Bootstrap

On container creation failure → log `model_container_bootstrap_failure` via AppLog (Crashlytics in Release).

On success:

1. Insert `LeagueState` if empty.
2. Seed default achievement if catalog empty.
3. Validate/sanitize state.

---

## 5. Deletion policy

- Deleting a tournament removes tournament-scoped state; players remain in the league.
- No "delete all data" in v1.0 Settings — planned for a future release with confirmation dialog.

---

## 6. Migration (future)

When schema changes **after first release**:

1. Version schemas (e.g. `SchemaV1`, `SchemaV2`) and a `SchemaMigrationPlan`.
2. Add migration tests in `BudgetLeagueTrackerTests`.
3. Update this spec and [docs/data-model.md](../docs/data-model.md).

Pre–1.0: no shipped stores — delete the simulator app or reset local data when the model changes.
