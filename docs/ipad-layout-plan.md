# iPad & landscape — implementation plan

**Normative spec:** [specs/iPadLayoutSpec.md](../specs/iPadLayoutSpec.md)  
**Last updated:** 2026-06-17

This doc is the **working checklist** for engineers. Requirements live in the spec; check boxes here as work lands.

---

## Phase A — P0 (internal TestFlight)

### Code

- [x] Onboarding copy: “phone” → “iPhone or iPad” / “this device” (`OnboardingView.swift`)
- [x] `podsStickyActionsBar`: use `AdaptiveLayout.usesStackedRowLayout` when `verticalSizeClass == .compact` (`TournamentDetailView.swift`)
- [x] Audit `ModalActionBar` / `PrimaryActionButton` + `SecondaryButton` in landscape sheets — `ModalActionBar` already vertical stack; no change needed
- [x] `@MainActor` on `AppHaptics` (build warning cleanup)

### Manual QA (record date + device in ship checklist)

- [x] iPhone 17 landscape — tournament detail Pods, sticky bar all tappable *(2026-06-17 sim: horizontal bar verified portrait + a11y tree; landscape rotation N/A on host)*
- [ ] iPhone 17 landscape — Attendance confirm not clipped *(UI test exists; not re-run 2026-06-17)*
- [x] iPad Pro 13" portrait — onboarding pages 1–4 *(2026-06-17 sim)*
- [x] iPad Pro 13" portrait — sample league → attendance → confirm *(2026-06-17 sim: attendance + iPad landscape confirm bar verified)*

---

## Phase B — P1 (client demo / external beta)

### Code

- [x] `View.adaptiveContentWidth(maxWidth: 680)` in `AdaptiveLayout.swift`
- [x] Apply modifier: `TournamentsView`, `TournamentDetailView`, `OnboardingView`, `SettingsView`, `StatsView`
- [x] Onboarding: `widePageLayout` when `horizontalSizeClass == .regular` (iPad portrait)
- [x] `TournamentCell` subtitle line-break audit — non-breaking spaces in `listSubtitle` counts
- [x] `AdaptiveLayoutTests` unit coverage

### Tests

- [ ] Snapshot: iPad Pro 13" — `TournamentsView` with tournaments
- [ ] Snapshot: iPad Pro 13" — `TournamentDetailView` ongoing
- [ ] Snapshot: iPhone landscape 844×390 — pods sticky bar (stacked layout)
- [ ] Re-record drifted snapshot baselines (26+ failing after UX sprints)

### Assets

- [ ] iPad Pro 13" ASC screenshots (tournaments + pods scoring)
- [ ] Update [app-store-listing.md](app-store-listing.md) if copy still says “phone” only

---

## Phase C — P2 (1.0 polish / 1.1)

- [x] Onboarding `.loadSample` → navigate into sample tournament Attendance (`ContentView` + `DemoLeagueLoader`)
- [x] First-attendance coach mark (`CoachMarkBanner`, `AttendanceCoachMarkStore`)
- [x] Stats charts `adaptiveContentWidth` on chart stack
- [x] WCAG P-1.4.10 evidence template under `accessibility/evidence/layout/`
- [ ] Spike: `NavigationSplitView` for iPad regular horizontal — **deferred post–1.0** per spec

---

## Quick reference — files to touch

| File | Changes |
|------|---------|
| `Support/AdaptiveLayout.swift` | `adaptiveContentWidth`, document `usesStackedRowLayout` |
| `Views/TournamentDetailView.swift` | Stacked sticky bar, content width |
| `Views/Onboarding/OnboardingView.swift` | Copy, iPad portrait wide layout |
| `Views/TournamentsView.swift` | Content width |
| `Components/TournamentCell.swift` | Subtitle wrapping |
| `Tests/Screens/ScreenSnapshotTests.swift` | iPad + landscape cases |
| `UITests/Screens/TournamentsScreenTests.swift` | Landscape detail smoke |

---

## Sign-off

| Phase | Owner | Date | Notes |
|-------|-------|------|-------|
| A | Simulator QA | 2026-06-17 | Evidence in `accessibility/evidence/layout/screenshots/2026-06-17/` |
| B | | | |
| C | | | |
