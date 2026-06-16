# Agent Build Checklist — League Keeper (0 → Ship)

Ordered checklist for building **League Keeper** from brainstorm to App Store. Focuses on engineering concepts, release discipline, and agent tooling.

**Status:** Living document — check boxes, add dates and commit hashes as phases complete.

**Last audited:** 2026-06-16  
**App:** League Keeper (`com.budgetleague.BudgetLeagueTracker`) · iOS 18+ · English MVP

---

## Agent query template (paste to start a new session)

```text
You are building League Keeper. Follow docs/agent-build-checklist.md.

Rules:
1. Spec-first: no user-visible behavior without an authoritative spec. One source of truth per concern.
2. Test-first for domain: pure logic and ViewModels get unit tests before UI polish.
3. Layered architecture: Views → ViewModels → Engine → Models. Engine never imports SwiftUI.
4. XcodeGen — regenerate the Xcode project; do not commit .xcodeproj.
5. Accessibility is a release gate (target WCAG 2.1 AA): VoiceOver, 44pt targets, Dynamic Type, contrast, supported orientations.
6. Use XcodeBuildMCP (or xcodebuild) for build/test; read .cursor/mcp.json for agent tooling.
7. Ship lean: v1.0 exposes full MVP surface (no ReleaseSurface module yet); hide post–1.0 work via specs/inventory, not compile flags.
8. Update this checklist and spec Verification blocks as phases complete.

Brainstorm / plans: docs/ios-app-plan.md (historical), docs/*-plan.md (active)
MVP scope: docs/feature-inventory.md · specs/README.md
Owner decisions: English only · Firebase in Release · no iCloud · min iOS 18
```

---

## Living document rules

| When | Update |
|------|--------|
| Phase completes | Check box + date + commit in **Progress log** |
| New screen ships | Feature spec Verification block + `accessibility/wcag-2.1-aa/screens/` entry |
| Ship status changes | `docs/feature-inventory.md` |
| Release scope changes | `docs/release/todo.md` + `docs/ios-roadmap.md` |
| New user-visible string | All bundled locale files + parity test *(when locales ship)* |
| New analytics/crash event | `specs/LoggingAnalyticsSpec.md` + allowlist + mapping tests |
| Pre-spec idea | `docs/*-plan.md` backlog — promote to `specs/` when rules lock |

**Source-of-truth hierarchy:** `specs/SpecGovernance.md` → system specs → feature plans → `docs/feature-inventory.md` → historical plans.

### Progress log

| Phase | Completed | Commit | Notes |
|-------|-----------|--------|-------|
| 0 | 2026-02-07 | `e467b43` | Repo, XcodeGen, folder layout, `.gitignore` |
| 0 | 2026-06-16 | `7ec4b9c` | SwiftLint, CI, MCP config, git hooks |
| 1 | 2026-06-16 | `7ec4b9c` | 13 system specs, governance, feature inventory |
| 2 | 2026-06-16 | `7ec4b9c` | Design tokens, WCAG tracker, contrast tests |
| 3 | 2026-02-07 | `2220897` | Engines + ViewModels + unit tests |
| 4 | 2026-02-07 | `e467b43` | SwiftData v1 (single schema; no repository layer by design) |
| 5 | 2026-02-07 | `ae45266` | App shell, tabs, onboarding scaffold |
| 6 | 2026-02-07 | `ae45266` | Tournament vertical slice |
| 7 | — | — | **In progress** — iPad/landscape partial ([ipad-layout-plan.md](ipad-layout-plan.md)) |
| 8 | 2026-06-16 | — | Settings + CRUD shipped; delete-all deferred |
| 9 | 2026-02-07 | `ae45266` | Stats, charts, player history |
| 10 | — | — | **Deferred** — English-only MVP (intentional) |
| 11 | — | — | **In progress** — automated audits pass; manual VO open |
| 12 | 2026-06-16 | `7ec4b9c` | PR CI + nightly UI; single UI target |
| 13 | — | — | **Not adopted** — MVP scope already narrow |
| 14 | 2026-06-16 | `7ec4b9c` | AppLog + Firebase scaffold; production plist pending |
| 15 | 2026-06-16 | — | HTML + launch screen; Pages + ASC pending |
| 16 | — | — | **Not started** — blocked on Phase 11 + TestFlight |
| 17 | — | — | Post–1.0 backlog in [ios-roadmap.md](ios-roadmap.md) |

---

## Phase 0 — Repo & agent infrastructure

- [x] **0.1** Create repo; `README.md` = build/run entry (links to `docs/` for product detail)
- [x] **0.2** **Project codegen:** XcodeGen `project.yml` — targets, schemes, SPM, build phases
- [x] **0.3** **Layered folders** (League Keeper layout):
  - `BudgetLeagueTracker/App/` — entry, splash, root shell
  - `BudgetLeagueTracker/Views/` — SwiftUI screens
  - `BudgetLeagueTracker/ViewModels/` — MVVM per flow
  - `BudgetLeagueTracker/Engine/` — pure business logic (no SwiftUI)
  - `BudgetLeagueTracker/Models/` — SwiftData `@Model` types
  - `BudgetLeagueTracker/DesignSystem/` — tokens, brand components
  - `BudgetLeagueTracker/Support/` — logging, flags, layout, onboarding stores
  - `BudgetLeagueTracker/Components/` — reusable UI
  - `Resources/` — launch storyboard, plist templates
  - `BudgetLeagueTrackerTests/`, `BudgetLeagueTrackerUITests/`
- [x] **0.4** Pin: iOS 18, bundle ID `com.budgetleague.BudgetLeagueTracker`, Swift 6 in `project.yml`
- [x] **0.5** `.gitignore`: generated `*.xcodeproj/`, `GoogleService-Info.plist`, DerivedData
- [x] **0.6** **Git hooks** — `.githooks/pre-commit` blocks Firebase plist; `Scripts/install-git-hooks.sh`
- [x] **0.7** **`.cursor/mcp.json`** — XcodeBuildMCP + ios-simulator
- [ ] **0.8** **Cursor rules** (`.cursor/rules/`) — a11y pointer, layout idioms, UI test ID conventions
- [x] **0.9** **SwiftLint** + CI lint job (`.github/workflows/ci.yml`)
- [x] **0.10** **CONTRIBUTING.md** — architecture, style, test expectations
- [x] **0.11** Verify: `xcodegen generate && xcodebuild` via `BudgetLeagueTrackerCI` scheme in CI

---

## Phase 1 — Spec system from brainstorm

- [ ] **1.1** Brainstorm in `FutureIdeas/` or `docs/brainstorm.md` — *ideas live in `docs/*-plan.md` instead*
- [x] **1.2** **System specs** (`specs/`):
  - [x] Architecture, Tech stack, Design system (`docs/design-system.md`)
  - [x] Data schema + persistence policy
  - [x] Accessibility requirements
  - [x] Test plan + CI gates
  - [x] Feature flags / logging (`LoggingAnalyticsSpec.md`)
  - [x] Spec governance
  - [x] iPad layout, App Store Connect, Scoring, Navigation, Achievement
- [x] **1.3** **Promotion pipeline** — informal via `polish-plan.md`, `achievement-improvements-plan.md`, `ipad-layout-plan.md`
- [ ] **1.4** Every feature spec ends with a **Verification** block (target release, date, commit, code paths)
- [x] **1.5** `specs/README.md` index + `docs/feature-inventory.md`
- [x] **1.6** Variant catalog — `AchievementTemplates`, `AchievementSpec.md` v2 roadmap

---

## Phase 2 — Design system & accessibility foundations

- [x] **2.1** **Token layers** — `DesignSystem/Tokens.swift`, brand asset colors, semantic palette
- [x] **2.2** Semantic colors light + dark; contrast tracked in `accessibility/wcag-2.1-aa/`
- [ ] **2.3** **Dynamic Type** — semantic styles in use; AXXXL manual pass open
- [ ] **2.4** **Touch targets** — 44×44 pt on primary controls; not fully evidenced per screen
- [x] **2.5** Reusable components — `AppAccessibility`, identifiers on key controls
- [x] **2.6** **WCAG tracker** — per-screen status + `evidence/` folder
- [x] **2.7** `BudgetLeagueTrackerTests/Accessibility/` — contrast + chart a11y tests
- [x] **2.8** Supported orientations documented — `specs/iPadLayoutSpec.md`, `specs/AccessibilitySpec.md`

---

## Phase 3 — Domain layer (test-first)

- [x] **3.1** `LeagueEngine`, `StatsEngine`, `AchievementStatsEngine` — zero SwiftUI imports
- [ ] **3.2** **Typed errors** at domain boundary — *errors mostly implicit today*
- [ ] **3.3** **State machines** — `LeagueState`, `OnboardingStore`; not formalized as machines
- [x] **3.4** Deterministic scoring, validation, aggregations
- [x] **3.5** Unit tests per engine + ViewModel (`BudgetLeagueTrackerTests/`)
- [ ] **3.6** Property-style simulation — not implemented
- [ ] **3.7** **Command pattern** — undo via `LeagueEngine.undoLastPod`; not generalized

---

## Phase 4 — Persistence & repositories

*League Keeper v1 intentionally skips a repository layer — ViewModels own SwiftData orchestration ([ArchitectureSpec.md](../specs/ArchitectureSpec.md) §3).*

- [ ] **4.1** Versioned schema (`SchemaV1`, `SchemaV2`) — v1 single schema; v2 planned for achievements
- [ ] **4.2** **Repository protocols** in `Data/` — not adopted in v1
- [x] **4.3** `ModelContainer` wired at app launch (`BudgetLeagueTrackerApp.swift`)
- [ ] **4.4** Migration tests in CI
- [ ] **4.5** Container bootstrap failure policy documented + tested
- [ ] **4.6** Features depend on `any FooRepository` — N/A for v1

---

## Phase 5 — App shell & navigation

- [x] **5.1** `@main` app struct + SwiftData bootstrap + `FirebaseBootstrap`
- [x] **5.2** Root navigation — `AppShell` → `ContentView` TabView; `specs/NavigationSpec.md`
- [ ] **5.3** **Router** for deep links / push — *onboarding sample-league navigation only*
- [x] **5.4** First-run **onboarding** — `OnboardingView`, `OnboardingStore`, demo league loader
- [x] **5.5** **Feature flags** — `FeatureFlagsProvider` (Firebase analytics/crashlytics)
- [ ] **5.6** **Release surface gate** — not adopted; MVP surface is the product

---

## Phase 6 — First vertical slice (MVP core journey)

**League Keeper slice:** create tournament → add players → weekly attendance → generate pods → score placements + achievements → weekly/final standings.

- [x] **6.1** Entry + resume — `TournamentsView`, ongoing/completed lists
- [x] **6.2** Configuration — `NewTournamentView`, weeks, achievement roll count
- [x] **6.3** Primary interaction — `AttendanceView`, pod scoring, placement picker
- [x] **6.4** Domain wired through ViewModels (no business rules in `View.body`)
- [x] **6.5** Completion — `TournamentStandingsView`, `WeekCompleteSheetView`, SwiftData persist
- [x] **6.6** Integration test — `TournamentLifecycleTests`, `ScoringIntegrationTests`
- [x] **6.7** UI test identifiers — `UITestBootstrap`, flow tests in `BudgetLeagueTrackerUITests/`

---

## Phase 7 — Shared chrome & adaptive layout

- [x] **7.1** Shared headers, empty states (`EmptyStateView`), coach marks, toasts
- [ ] **7.2** **Non-color state indicators** — partial (placement icons; charts rely on color)
- [x] **7.3** Loading, disabled, destructive patterns (`PrimaryActionButton`, `DestructiveActionButton`)
- [ ] **7.4** **Orientation support** — `AdaptiveLayout`, landscape menu pickers; P0 QA open
- [ ] **7.5** iPad predicates — `adaptiveContentWidth()` partial; `NavigationSplitView` post–1.0
- [x] **7.6** Secondary journeys — players, achievements, stats beyond tournament core

---

## Phase 8 — Entity management & settings

- [x] **8.1** CRUD — players, achievements, tournaments (create/edit/delete)
- [x] **8.2** Identity — player names, achievement catalog
- [x] **8.3** **Settings** — theme, about, support/privacy links, replay onboarding
- [ ] **8.4** Settings ViewModel tests — *Settings is view-only today*
- [x] **8.5** **AppLinks** — `AppInfo.supportURL`, `AppInfo.privacyURL`
- [x] **8.6** Tip/donate row — N/A (`nil` = hidden; not in scope)
- [ ] **8.7** **Delete all local data** — planned post–1.0 ([DataSchemaSpec.md](../specs/DataSchemaSpec.md))

---

## Phase 9 — Lists, history & derived views

- [x] **9.1** List + detail — tournaments, players, tournament detail tabs
- [ ] **9.2** Filters and search — not implemented (small local datasets)
- [x] **9.3** Aggregations and charts — `StatsView`, bar/line/pie charts
- [x] **9.4** Batch fetching — N/A at current data scale
- [x] **9.5** Segment pickers — stats segments, tournament detail tabs

---

## Phase 10 — Localization & text coverage

*Lean v1: English only per `specs/README.md` MVP baseline.*

- [ ] **10.1** String catalog wrapper (`L10n` / `String(localized:)`)
- [ ] **10.2** `en.lproj` source of truth
- [ ] **10.3** PR rule: all locales simultaneously
- [ ] **10.4** Parity test across `.lproj` files
- [ ] **10.5** Locale smoke UI tests
- [x] **10.6** **Lean ship:** bundle English only in v1.0 release
- [ ] **10.7** Translation sync scripts

---

## Phase 11 — Accessibility hardening (release gate) ← **CURRENT FOCUS**

- [x] **11.1** Automated UI accessibility audits — `AccessibilityAuditTests`
- [ ] **11.2** Manual **VoiceOver** pass — [accessibility/Manual_todo.md](../accessibility/Manual_todo.md)
- [ ] **11.3** **Large text (AXXXL+)** — critical screens without clipping
- [ ] **11.4** **Contrast evidence** — light/dark on primary actions (partial evidence in `evidence/`)
- [ ] **11.5** **Orientation matrix** — portrait/landscape × phone/pad on core screens
- [ ] **11.6** **Reduce Motion** — partial (`AppShell`, `SplashView`, `OnboardingView`)
- [ ] **11.7** Hide decorative elements from VoiceOver — spot-check open
- [ ] **11.8** Accessibility statement link from Settings — HTML exists; in-app link missing
- [ ] **11.9** Rollup: zero Required **Fail** on core flows — tracker status **Not compliant** ([SUMMARY.md](../accessibility/wcag-2.1-aa/SUMMARY.md))

---

## Phase 12 — Test matrix & CI

- [x] **12.1** PR CI scheme `BudgetLeagueTrackerCI` — lint + unit + coverage summary
- [ ] **12.2** **Split UI tests** by concern — single `BudgetLeagueTrackerUI` target today
- [x] **12.3** Nightly UI workflow — `.github/workflows/nightly-ui.yml`
- [x] **12.4** Launch arguments — `--uitesting`, seed scenarios, theme/screenshot args
- [x] **12.5** Test doubles — in-memory `ModelContainer`, `TestFixtures`, `UITestBootstrap`
- [ ] **12.6** Spec/code drift script in CI
- [x] **12.7** Block tracked secrets in CI (Firebase plist)

---

## Phase 13 — Release surface & lean ship strategy

*Not adopted — v1.0 ships the full MVP; post–1.0 features gated via feature inventory and specs.*

- [ ] **13.1** `ReleaseSurface` / `ProductSurface` module
- [ ] **13.2** One place controls tabs, menus, deep links, locales
- [ ] **13.3** `-enable_full_product_surface` launch argument for dogfood
- [x] **13.4** Written **lean v1 plan** — [feature-inventory.md](feature-inventory.md), [ios-roadmap.md](ios-roadmap.md)
- [ ] **13.5** **Test-confidence matrix** — partial ([ipad-layout-plan.md](ipad-layout-plan.md), [1.0-ship-checklist.md](release/1.0-ship-checklist.md))
- [ ] **13.6** Branch model `dev` vs `release/*`
- [ ] **13.7** Per-feature release tags in specs + registry

---

## Phase 14 — Telemetry, deep links & platform extensions

- [x] **14.1** Secrets template — `Resources/GoogleService-Info.plist.example`; real plist gitignored
- [x] **14.2** **Allowlisted analytics** — `FirebaseAnalyticsEventMapping` + tests; off in Debug/CI
- [ ] **14.3** Crash reporting + dSYM upload — scaffold in `project.yml`; needs production plist
- [x] **14.4** Structured logging — `AppLog`, console + Firebase sinks
- [ ] **14.5** **Deep links** — general parser/router not implemented
- [ ] **14.6** App Intents / Shortcuts
- [ ] **14.7** Widgets, Live Activities, Watch

---

## Phase 15 — Legal pages, GitHub Pages & store URLs

- [x] **15.1** Static HTML — `docs/privacy.html`, `support.html`, `accessibility.html`, `index.html`
- [ ] **15.2** Enable **GitHub Pages** — [github-pages.md](github-pages.md)
- [x] **15.3** Canonical URLs in `AppInfo` → `jacobrozell.github.io/League-Keeper-iOS/…`
- [ ] **15.4** App Store Connect record + live URL verification
- [ ] **15.5** Bump "Last updated" when practices change
- [x] **15.6** App Store metadata spec — [AppStoreConnectSpec.md](../specs/AppStoreConnectSpec.md), [app-store-listing.md](app-store-listing.md)
- [ ] **15.7** Marketing screenshots + snapshot automation
- [x] **15.8** Launch screen — `Resources/LaunchScreen.storyboard` + asset catalog
- [ ] **15.9** CI/CD for TestFlight — [release/testflight.md](release/testflight.md)

---

## Phase 16 — Release QA & ship

- [ ] **16.1** Device matrix scoped to v1.0 surface — [1.0-ship-checklist.md](release/1.0-ship-checklist.md)
- [ ] **16.2** RC sign-off doc with Go/No-Go
- [ ] **16.3** Owner decisions closed (locales, telemetry, bundle ID)
- [ ] **16.4** Lean-surface UI smoke green
- [ ] **16.5** Persistence recovery smoke on physical device
- [ ] **16.6** Pre-tag gate checklist (~10 min)
- [ ] **16.7** Post-submit monitoring plan

---

## Phase 17 — Expand surface (post-v1)

Backlog: iCloud sync, achievement v2, `NavigationSplitView`, export, additional locales. See [ios-roadmap.md](ios-roadmap.md).

For each slice: update inventory → run device QA → update WCAG screens → tag and ship.

---

## Phase 18 — Documentation hygiene (ongoing)

- [ ] **18.1** Behavior PR → spec Verification block
- [x] **18.2** Feature inventory maintained ([feature-inventory.md](feature-inventory.md))
- [ ] **18.3** Spec/code drift report in CI
- [ ] **18.4** Engineering audit after large refactors
- [ ] **18.5** Document extractions before splitting god ViewModels
- [ ] **18.6** Release automation runbooks

---

## Quick reference for agents

| Question | Where to look |
|----------|---------------|
| What should the product do? | `specs/*.md` |
| What exists in the build today? | [feature-inventory.md](feature-inventory.md) |
| How is code organized? | [architecture.md](architecture.md) + [ArchitectureSpec.md](../specs/ArchitectureSpec.md) |
| How do I build and test? | [README.md](../README.md), [development.md](development.md), `.cursor/mcp.json` |
| What ships this sprint? | [release/todo.md](release/todo.md) |
| Accessibility requirements? | [AccessibilitySpec.md](../specs/AccessibilitySpec.md) + [wcag-2.1-aa/](../accessibility/wcag-2.1-aa/) |
| iPad / landscape? | [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) + [ipad-layout-plan.md](ipad-layout-plan.md) |
| Legal / support URLs? | `docs/*.html` + `AppInfo` |
| Ideas not yet spec'd? | `docs/*-plan.md` |
| **This checklist** | `docs/agent-build-checklist.md` |

---

## Next actions (2026-06-16)

1. Close **Phase 11** — VoiceOver core flow, chart a11y, AXXXL, landscape evidence
2. Close **Phase 7 P0** — iPad/landscape QA per [ipad-layout-plan.md](ipad-layout-plan.md)
3. Enable **GitHub Pages** (Phase 15.2)
4. First **TestFlight** upload (Phase 16)
5. Add **Verification** blocks to specs as gates close (Phase 1.4)
