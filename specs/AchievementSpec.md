# Achievement specification

Normative rules for the league achievement catalog, creation/editing UI, icons, templates, and scoring behavior.

**User-facing summary:** [docs/domain-glossary.md](../docs/domain-glossary.md), [docs/scoring-rules.md](../docs/scoring-rules.md)  
**Implementation plan:** [docs/achievement-improvements-plan.md](../docs/achievement-improvements-plan.md)  
**Status:** Planned (post–1.0 polish)

---

## 1. Purpose

Achievements are **global catalog entries** shared across tournaments. Each week, a subset becomes **active** (always-on achievements plus a random sample). During pod scoring, the host marks which players earned which active achievements.

This spec extends the v1 model (`name`, `points`, `alwaysOn`) with metadata that helps hosts **explain rules at the table**, **balance points against placement**, and **score faster** with icons, descriptions, and exclusivity rules.

---

## 2. Entity: `Achievement`

### 2.1 Persisted fields

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `id` | `String` | yes | new UUID | Stable reference in `GameResult`, tournament weekly state |
| `name` | `String` | yes | — | Display name; trimmed; non-empty; max 80 characters |
| `points` | `Int` | yes | `1` | Awarded when earned; range `0…99` (unchanged from v1) |
| `alwaysOn` | `Bool` | yes | `false` | If true, included in every week's active set |
| `achievementDescription` | `String?` | no | `nil` | Short rule text; max 200 characters; **not** named `description` (SwiftData / NSObject collision) |
| `categoryRaw` | `String` | yes | `"custom"` | See §3.1 |
| `iconName` | `String` | yes | `"trophy.fill"` | SF Symbol name; must exist in catalog allowlist (§4) |
| `exclusivityRaw` | `String` | yes | `"unlimited"` | See §3.2 |

### 2.2 Computed / derived (not persisted)

| Concept | Rule |
|---------|------|
| `pointsTier` | Derived from `points` via `AppConstants.Achievement.pointsTier(for:)` (§3.3) |
| `availabilityLabel` | UI copy: `alwaysOn == true` → "Every week"; else → "Random pool" |

### 2.3 Invariants

| Rule | Enforcement |
|------|-------------|
| `name` non-empty after trim | `LeagueEngine.addAchievement` / `updateAchievement` |
| `points` ∈ `0…99` | Engine clamp + UI stepper/preset bounds |
| `iconName` ∈ allowlist | UI picker only; engine falls back to `"trophy.fill"` if invalid |
| `categoryRaw` ∈ enum cases | Engine falls back to `.custom` if unknown |
| `exclusivityRaw` ∈ enum cases | Engine falls back to `.unlimited` if unknown |
| Achievement deletion | Existing `GameResult` records keep earned IDs; stats engine resolves names best-effort |

### 2.4 Migration from v1

Existing achievements gain defaults on schema upgrade:

- `achievementDescription` → `nil`
- `categoryRaw` → `"custom"`
- `iconName` → `"trophy.fill"`
- `exclusivityRaw` → `"unlimited"`

No change to `points`, `alwaysOn`, or historical scoring.

---

## 3. Enumerations

### 3.1 `AchievementCategory`

| Case | Raw value | Default icon | UI label |
|------|-----------|--------------|----------|
| `combat` | `combat` | `flame.fill` | Combat |
| `deckbuilding` | `deckbuilding` | `rectangle.stack.fill` | Deckbuilding |
| `social` | `social` | `person.3.fill` | Social |
| `chaos` | `chaos` | `dice.fill` | Chaos |
| `seasonal` | `seasonal` | `leaf.fill` | Seasonal |
| `custom` | `custom` | `trophy.fill` | Custom |

Category affects **default icon suggestion** when creating from template or changing category. It does not affect scoring math.

### 3.2 `AchievementExclusivity`

| Case | Raw value | UI label | Scoring behavior |
|------|-----------|----------|------------------|
| `unlimited` | `unlimited` | Anyone can earn | Multiple players in a pod may earn full points (v1 behavior) |
| `onePerPod` | `onePerPod` | One player per pod | At most one player per pod may have this achievement checked; checking one unchecks others in the same pod |
| `onePerWeekPerPlayer` | `onePerWeekPerPlayer` | Once per week per player | Player may earn at most once per tournament week across all rounds; UI disables toggle if already earned earlier in the week |

`onePerWeekPerPlayer` is evaluated against saved `GameResult` rows for the active tournament and current week, not merely the in-progress pod UI state.

### 3.3 `AchievementPointsTier`

UI-facing presets; persisted value remains `points`.

| Tier | Points | UI label | Placement context (helper copy) |
|------|--------|----------|-----------------------------------|
| `small` | `1` | Small bonus | About half a 4th-place finish |
| `standard` | `2` | Standard | Like moving up one placement |
| `big` | `3` | Big swing | Worth a full placement jump |
| `trophy` | `4` | Trophy | Rare / hard to earn |

Custom numeric override: advanced stepper or text field still allowed; tier highlight reflects nearest tier or "Custom".

Mapping lives in `AppConstants.Achievement`.

---

## 4. Icon system

### 4.1 Requirements

- Icons are **SF Symbols** (`Image(systemName:)`), not custom image assets.
- Host can **change icon** when creating or editing an achievement.
- Icon appears in: achievement list row, add/edit preview card, "This week's achievements" on Pods, and achievement check rows during scoring.

### 4.2 Picker UX

| Requirement | Detail |
|-------------|--------|
| Layout | Grid of tappable cells, minimum 44×44 pt touch target per `AppConstants.UI.minTouchTargetHeight` |
| Selection | Selected icon shows gold ring / checkmark (`BrandGold`) |
| Grouping | Sections by category name (Combat, Deckbuilding, …) **or** flat grid with category filter chips — implementation may choose; both must meet a11y |
| Default | When category changes, suggest category default icon if user has not manually picked a custom icon |
| Search | Optional in v2.1; not required for initial ship |

### 4.3 Allowlist

Icons must come from `AppConstants.Achievement.iconAllowlist` — a curated list of ~40–60 symbols appropriate for tabletop / league flavor. Examples:

| Category | Symbols (non-exhaustive) |
|----------|--------------------------|
| Combat | `flame.fill`, `bolt.fill`, `scope`, `burst.fill`, `shield.fill` |
| Deckbuilding | `rectangle.stack.fill`, `square.grid.3x3.fill`, `paintpalette.fill`, `sparkles` |
| Social | `person.3.fill`, `hand.wave.fill`, `heart.fill`, `megaphone.fill` |
| Chaos | `dice.fill`, `questionmark.circle.fill`, `wand.and.stars` |
| Seasonal | `leaf.fill`, `snowflake`, `sun.max.fill`, `moon.fill` |
| General | `trophy.fill`, `star.fill`, `medal.fill`, `crown.fill`, `flag.fill`, `target` |

Invalid stored `iconName` at read time → render `trophy.fill`.

### 4.4 Accessibility

- Each icon cell: `accessibilityLabel` = human name (e.g. "Flame icon").
- Selected state: `accessibilityValue` = "selected".
- List rows: `accessibilityLabel` includes achievement name, points, and category when relevant.

---

## 5. Templates

### 5.1 Purpose

Reduce blank-slate friction for new hosts. Templates are **not** persisted rows; they are compile-time definitions used to pre-fill the add/edit form.

### 5.2 Template catalog

Defined in `AppConstants.Achievement.templates` (or `AchievementTemplates.swift`). Each template provides:

- `name`, `achievementDescription`, `points`, `alwaysOn`, `category`, `iconName`, `exclusivity`

Minimum shipped set (10 templates):

| Name | Pts | Always on | Category | Exclusivity |
|------|-----|-----------|----------|-------------|
| First Blood | 1 | no | combat | onePerPod |
| Combat Damage Master | 2 | no | combat | onePerPod |
| Five-Color Flavor | 1 | yes | deckbuilding | unlimited |
| Mono Master | 1 | no | deckbuilding | unlimited |
| Combo Conductor | 2 | no | deckbuilding | onePerPod |
| Table Captain | 1 | no | social | unlimited |
| Good Sport | 1 | no | social | unlimited |
| Chaos Agent | 2 | no | chaos | unlimited |
| Underdog Win | 3 | no | combat | onePerPod |
| Perfect Round | 4 | no | combat | onePerWeekPerPlayer |

Hosts may edit all fields before saving.

### 5.3 Add flow entry points

| Entry | Behavior |
|-------|----------|
| **Blank custom** | Empty form with defaults |
| **From template** | Picker list → pre-filled form |
| **Duplicate** | From achievement row menu → form pre-filled from existing (new `id` on save) |

---

## 6. UI surfaces

### 6.1 Achievements tab (`AchievementsView`)

| Element | Requirement |
|---------|-------------|
| List row | Icon + name + points + availability badge + category chip (optional) |
| Row tap | Opens **edit** sheet (replaces menu-only always-on toggle as primary path) |
| Row menu | Duplicate, toggle always-on, remove (destructive, confirm if earned count > 0) |
| Balance summary | Footer card: catalog size, always-on count, expected weekly active count given default tournament settings (§7) |
| Add button | Presents template picker → builder sheet |

### 6.2 Achievement builder (`AchievementFormView`)

Shared by **New** and **Edit**. Replaces `NewAchievementView` layout.

| Section | Contents |
|---------|----------|
| **Preview card** | Live preview: icon, name, description, points tier badge, availability, exclusivity |
| **Details** | Name field, description field (optional, character count) |
| **Value** | Points tier picker (§3.3) + optional "Custom points" disclosure with stepper |
| **Availability** | Segmented or picker: "Every week" / "Random pool" (maps to `alwaysOn`) |
| **Exclusivity** | Picker with short footnote explaining each option |
| **Category** | Picker; changing category suggests icon if not manually overridden |
| **Icon** | `AchievementIconPicker` grid (§4.2) |
| **Primary action** | "Add Achievement" or "Save Changes" |

Edit mode shows non-blocking note: *"Changes apply to future scoring. Past results are unchanged."*

### 6.3 Tournament detail — Pods tab

| Element | Requirement |
|---------|-------------|
| This week's achievements | Icon + name + points; description as secondary line or info button |
| Achievement check row | Icon + name + `+N`; tap name shows description popover/sheet |
| Exclusivity | Enforce `onePerPod` and `onePerWeekPerPlayer` in `PodsViewModel` / `LeagueEngine` |

### 6.4 Edit last round

`EditLastRoundView` shall display the same icon + description affordances and respect exclusivity when toggling checks.

---

## 7. League balance summary

Displayed on Achievements tab when catalog has ≥1 achievement.

**Inputs:**

- `catalogCount` — total achievements
- `alwaysOnCount` — achievements with `alwaysOn == true`
- `defaultRandomPerWeek` — `AppConstants.League.defaultRandomAchievementsPerWeek` (or active tournament's value if one is active — implementation choice; document in plan)

**Computed copy (example):**

- Expected active per week ≈ `alwaysOnCount + defaultRandomPerWeek`
- Average points per active achievement (catalog mean)
- Placement band per round: 1–4 points per player from placement

**Guidance tiers (non-blocking):**

| Condition | Message |
|-----------|---------|
| Avg achievement pts × expected active > 12 | "Achievement points may dominate placement — consider lowering values or reducing random count." |
| Always-on > 6 | "Many always-on achievements — random pool may feel redundant." |
| Catalog < 3 | "Add a few more for variety each week." |

---

## 8. Scoring integration

### 8.1 Unchanged from v1

- Weekly roll: `LeagueEngine.rollActiveAchievements` — always-on + random sample
- Points added to weekly + lifetime totals on pod save
- `achievementsOnThisWeek` attendance toggle still gates all achievement UI and awards

### 8.2 Exclusivity enforcement

| Rule | When enforced |
|------|---------------|
| `onePerPod` | On toggle **on** in current pod UI: uncheck same achievement for other players in pod before save; validate on save |
| `onePerWeekPerPlayer` | Disable toggle if player already has achievement ID in a saved `GameResult` for current week; validate on save |

Undo and edit-last-round must re-validate exclusivity after changes.

### 8.3 Spec cross-reference

Update [ScoringSpec.md](ScoringSpec.md) §2 when exclusivity ships.

---

## 9. Engine API

Extend `LeagueEngine`:

```swift
// Create
static func addAchievement(
    context: ModelContext,
    name: String,
    points: Int,
    alwaysOn: Bool,
    achievementDescription: String? = nil,
    category: AchievementCategory = .custom,
    iconName: String = "trophy.fill",
    exclusivity: AchievementExclusivity = .unlimited
) -> Achievement?

// Update (new)
static func updateAchievement(
    context: ModelContext,
    id: String,
    name: String,
    points: Int,
    alwaysOn: Bool,
    achievementDescription: String?,
    category: AchievementCategory,
    iconName: String,
    exclusivity: AchievementExclusivity
) -> Bool

// Existing
static func removeAchievement(...)
static func setAchievementAlwaysOn(...) // may deprecate in favor of updateAchievement
```

---

## 10. Analytics (optional)

If events are added, follow [LoggingAnalyticsSpec.md](LoggingAnalyticsSpec.md). Allowed examples:

- `achievement_created` — properties: `category`, `points_tier`, `from_template` (bool)
- `achievement_edited` — no player-identifying data

---

## 11. Accessibility

New / updated WCAG screen files:

- `accessibility/wcag-2.1-aa/screens/new-achievement.md` → rename scope to **achievement-form**
- New: `accessibility/wcag-2.1-aa/screens/achievement-icon-picker.md`

Requirements:

- Icon grid navigable with VoiceOver
- Description fields labeled; character count not sole indicator of limit
- Exclusivity options read with full label + hint
- Preview card not redundant with form fields (combine or hide from VO)

---

## 12. Change control

Achievement feature changes require:

1. This spec
2. [DataSchemaSpec.md](DataSchemaSpec.md) + [docs/data-model.md](../docs/data-model.md)
3. [ScoringSpec.md](ScoringSpec.md) if exclusivity or awards change
4. `Achievement` model + migration
5. `LeagueEngine` + ViewModels
6. Unit tests: model, engine, exclusivity integration
7. UI tests: add from template, edit, icon pick
8. WCAG screen updates
9. [docs/feature-inventory.md](../docs/feature-inventory.md)

---

## 13. Out of scope (v2)

| Item | Notes |
|------|-------|
| Custom user-uploaded images | SF Symbols only |
| Per-tournament achievement catalogs | Achievements remain global |
| Achievement search in catalog | Defer until catalog > ~20 |
| Localization of template strings | English only per MVP |
| Achievement icons in shared standings export | Future polish |
