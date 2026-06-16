# iPad & landscape layout specification

**Status:** Planned (pre–TestFlight polish)  
**Last updated:** 2026-06-16  
**Owner:** Product + iOS  
**Related:** [AdaptiveLayout.swift](../BudgetLeagueTracker/Support/AdaptiveLayout.swift), [AccessibilitySpec.md](AccessibilitySpec.md), [TestPlanSpec.md](TestPlanSpec.md)

---

## 1. Purpose

League Keeper ships as a **universal** iOS app (iPhone + iPad). Hosts may run a league from an iPad at the table or rotate an iPhone to landscape while scoring pods.

This spec defines:

- What **must** work for TestFlight / 1.0 (no clipped CTAs, readable layout)
- What **should** improve perceived quality on large screens
- What is **explicitly deferred** to post–1.0

**Normative:** Sections marked **Required** are release gates. **Recommended** items are strongly encouraged before external beta. **Future** items are documented so nothing is forgotten.

---

## 2. Goals & non-goals

### Goals (1.0)

| Goal | Rationale |
|------|-----------|
| All primary actions reachable on iPad and in landscape | Host cannot miss Confirm Attendance, Generate Pods, Finish Round |
| No critical content clipped by tab bar, keyboard, or sticky bars | Regression from Sprint 1 tab-bar CTA fix |
| Readable line lengths on iPad (not edge-to-edge phone stretch) | Client demo on iPad Pro |
| Consistent copy (“device”, not “phone”) | Onboarding already mentions iPad |
| Documented manual QA matrix | Ship checklist + WCAG P-1.4.10 evidence |

### Non-goals (1.0)

| Out of scope | Notes |
|--------------|-------|
| `NavigationSplitView` / sidebar master–detail | Post–1.0 iPad-native chrome |
| Multitasking / Stage Manager window sizing matrix | Smoke-test default size only |
| iPad-only features (Apple Pencil, keyboard shortcuts) | Future |
| Separate iPad App Store screenshots art direction | Use standard ASC sizes; see §8 |

---

## 3. Current state (2026-06-16 audit)

Simulator walkthrough: fresh iPad install → onboarding → Load sample league → tournament detail (Attendance).

| Area | Status | Issue |
|------|--------|-------|
| Functional correctness | **Pass** | Sample league, attendance, navigation work |
| Onboarding (iPad portrait) | **Partial** | Content clustered at top; large empty vertical band |
| Onboarding copy | **Fail** | “from your phone” on page 1 |
| Tab chrome (iPad) | **Acceptable** | iOS 18 floating tab bar; phone-scaled, not broken |
| Tournament list (iPad) | **Partial** | Full-width rows; excessive horizontal whitespace |
| Tournament detail (iPad) | **Partial** | Wide attendance toggles; CTAs visible |
| Landscape (iPhone) | **Untested / at risk** | Sticky 2×2 pods action bar; short content area |
| `usesStackedRowLayout` | **Not wired** | Helper exists in `AdaptiveLayout` but unused |
| `horizontalSizeClass` handling | **None** | No max-width column anywhere |
| WCAG P-1.4.10 (reflow) | **Untested** | [SUMMARY.md](../accessibility/wcag-2.1-aa/SUMMARY.md) |

---

## 4. Design principles

1. **iPhone-first, iPad-compatible** — Optimize for phone-at-the-table; iPad gets constrained width and spacing, not a second app.
2. **Size class over device idiom** — Use `horizontalSizeClass` / `verticalSizeClass`, not `UIDevice.current.userInterfaceIdiom == .pad`.
3. **CTAs stay pinned** — Bottom `safeAreaInset` patterns from tournament detail and attendance are the reference; never regress.
4. **Landscape = compact height** — When `verticalSizeClass == .compact`, prefer stacked controls and menu pickers (already used for section tabs).
5. **One modifier, many screens** — Introduce a shared content-width wrapper rather than per-view magic numbers.

---

## 5. Layout tokens & helpers

### 5.1 Content width (new — **Required**)

| Token | Value | When |
|-------|-------|------|
| `contentMaxWidth` | **680 pt** | `horizontalSizeClass == .regular` (iPad portrait, iPad landscape, iPhone Plus landscape) |
| `contentMaxWidthLandscapePhone` | **600 pt** | Optional tighter cap on iPhone landscape if needed after QA |

Apply to: root tab stacks, onboarding scroll content, tournament detail outer `VStack`, full-screen covers where content is form-like.

**Implementation sketch:** `View.adaptiveContentWidth()` modifier in `AdaptiveLayout.swift` or `DesignSystem/`.

### 5.2 Existing helpers (extend)

| Helper | Current behavior | Planned change |
|--------|------------------|----------------|
| `usesMenuSectionPicker` | Menu when `verticalSizeClass == .compact` **or** `dynamicType.isAccessibilitySize` | Done — tournament detail + Stats |
| `usesStackedRowLayout` | Defined, **unused** | **Required:** pods sticky bar, modal action rows in compact height |
| `tabBarClearance` | AXXXL empty states | Keep; verify iPad landscape empty states |
| Onboarding `widePageLayout` | `compactHeight && !largeText` | **Required:** also true when `horizontalSizeClass == .regular` on onboarding pages |

### 5.3 Typography & touch

- Reuse existing `AppConstants.UI.minTouchTargetHeight` (44 pt).
- Do not cap Dynamic Type on iPad beyond existing per-component caps.
- List rows on iPad: prefer inset grouped list as today; width constraint handles stretch.

---

## 6. Screen-by-screen requirements

### 6.1 App shell & tabs

| Item | Priority | Requirement |
|------|----------|-------------|
| Tab bar on iPad | Required | May remain floating iOS 18 tab bar; no custom sidebar in 1.0 |
| Focus mode (hide tab bar in tournament detail) | Required | Unchanged |
| Branded splash | Required | Center crest; no clipped assets at any idiom |
| `adaptiveContentWidth` on tab roots | Recommended | Tournaments, Players, Stats, Achievements, Settings |

### 6.2 Onboarding

| Item | Priority | Requirement |
|------|----------|-------------|
| Copy page 1 | **Required** | “from your phone” → “from your iPhone or iPad” (or “from this device”) |
| iPad portrait layout | **Required** | Enable wide/centered layout when `horizontalSizeClass == .regular` (hero + text side-by-side OR centered card max 680 pt) |
| iPad landscape layout | Required | Existing `widePageLayout` path; verify footer actions not clipped |
| Final page CTAs | Recommended | After “Load sample league”, optional navigation into sample tournament Attendance tab (see §7) |
| Reduce Motion | Required | Unchanged |

### 6.3 Tournaments list

| Item | Priority | Requirement |
|------|----------|-------------|
| `TournamentCell` subtitle | Required | No awkward mid-phrase line breaks at default Dynamic Type on iPhone (audit “4” / “players” wrap) |
| iPad width | Recommended | List content respects `contentMaxWidth`, centered |
| Empty state | Required | Primary CTA visible above tab bar (existing `adaptiveEmptyStateLayout`) |
| Landscape iPhone | Required | Nav bar + Add button hittable; UI test already covers existence |

### 6.4 Tournament detail (highest risk)

| Item | Priority | Requirement |
|------|----------|-------------|
| `TournamentProgressHeader` | Required | Step labels remain readable; `minimumScaleFactor(0.8)` acceptable; no overlap |
| Section picker | Required | Segmented (portrait) / menu (landscape) — already implemented |
| Attendance tab | Required | Confirm Attendance pinned; list scrolls independently |
| Pods tab — sticky actions | **Required** | When `usesStackedRowLayout` → single column: Generate, Finish Round, then secondary row or stacked Edit buttons |
| Pods tab — scroll region | Required | With sticky bar + header, at least one pod section or empty state fully visible without scrolling on iPhone 15 landscape |
| Placement picker | Required | Segmented 1st–4th; if clipped at AXL, allow horizontal scroll within row (audit) |
| Week complete sheet | Required | Readable on iPad; buttons reachable |
| Champion / completed header | Recommended | `adaptiveContentWidth` on summary block |

### 6.5 Attendance (standalone sheet / flow)

| Item | Priority | Requirement |
|------|----------|-------------|
| Confirm Attendance inset | Required | Same as embedded tab |
| Mark all / Clear all | Required | Visible in landscape |
| Add player field | Required | Not hidden by keyboard on iPad split keyboard |

### 6.6 Stats & charts

| Item | Priority | Requirement |
|------|----------|-------------|
| Section picker | Required | Menu in landscape (existing) |
| Charts | Recommended | Max width on iPad; chart VoiceOver separate track ([accessibility_todo.md](../accessibility/accessibility_todo.md)) |
| Landscape | Required | Segment content scrolls; no clipped chart titles |

### 6.7 Players, achievements, settings

| Item | Priority | Requirement |
|------|----------|-------------|
| Standard lists | Recommended | `adaptiveContentWidth` |
| Settings crest header | Recommended | Centered block on iPad |
| New tournament / add players forms | Required | Fields usable on iPad; no truncated labels in landscape |

### 6.8 Sheets & modals

| Sheet | Requirement |
|-------|-------------|
| `EditLastRoundView` | Scroll + primary save visible |
| `EditTournamentView` | Same |
| `WeekCompleteSheetView` | Standings list scrolls; Continue pinned |
| `TournamentStandingsView` (cover) | Dismiss + content reachable on iPad |

---

## 7. Demo & onboarding flow (client-ready)

**Recommended** for TestFlight narrative (not a layout spec per se, but documented here so it is not lost):

| Step | Current | Planned |
|------|---------|---------|
| Fresh install | Onboarding → sample league → tournaments list | Same |
| After Load sample | User must tap tournament | **Optional P1:** `DemoLeagueLoader` + onboarding completion opens `Kitchen Table League` on Attendance tab |
| Settings replay | “View welcome tour” | Keep |

---

## 8. App Store & marketing

From [AppStoreConnectSpec.md](AppStoreConnectSpec.md):

| Asset | iPad requirement |
|-------|------------------|
| 12.9" / 13" iPad Pro screenshots | **Required** for universal app submission |
| Screenshot content | Tournaments list + tournament detail (pods) minimum |
| Listing copy | Already says “phone” in places — align with onboarding copy pass |

Store in `marketing-screenshots/ipad/` when captured.

---

## 9. Accessibility & WCAG

| Criterion | Requirement |
|-----------|-------------|
| P-1.4.10 Reflow | Manual evidence: portrait + landscape on tournament detail and stats ([Manual_todo.md](../accessibility/Manual_todo.md)) |
| P-1.4.4 Resize text | AXXXL spot-check on iPad tournament detail |
| Touch targets | 44 pt on sticky bar buttons in stacked layout |
| VoiceOver | No regression; tab menu pickers announce section |

Update WCAG screen files when layout changes land.

---

## 10. Implementation phases

### Phase A — P0 (before internal TestFlight)

**Gate:** No clipped CTAs; onboarding copy fixed.

- [x] Fix onboarding copy (“device” not “phone”)
- [x] Wire `usesStackedRowLayout` into `podsStickyActionsBar` (and `ModalActionBar` if shared)
- [ ] Manual QA: iPhone landscape tournament detail Pods tab (sticky bar + empty state + 1 pod expanded)
- [ ] Manual QA: iPad portrait core flow (onboarding → sample → attendance confirm → generate pods)

### Phase B — P1 (before external beta / client demo)

**Gate:** iPad does not look like broken phone stretch.

- [x] Add `adaptiveContentWidth()` modifier (~680 pt)
- [x] Apply to tournaments list, tournament detail, onboarding
- [x] Onboarding iPad portrait: `widePageLayout` or centered card when `horizontalSizeClass == .regular`
- [x] Audit `TournamentCell` subtitle wrapping
- [ ] Snapshot tests: iPad Pro 13" portrait for tournaments + tournament detail; iPhone landscape for pods sticky bar
- [ ] iPad Pro screenshots for ASC

### Phase C — P2 (1.0 polish or 1.1)

- [x] Deep-link sample league into tournament after onboarding
- [x] Stats charts max-width on chart stack
- [x] First-attendance coach mark (see [tournament-ux-improvements.md](../docs/tournament-ux-improvements.md))
- [x] WCAG P-1.4.10 evidence template — [accessibility/evidence/layout/ipad-landscape-2026-06-16.md](../accessibility/evidence/layout/ipad-landscape-2026-06-16.md)
- [ ] Landscape snapshot tests for pods sticky bar
- [ ] Optional: `NavigationSplitView` spike — deferred post–1.0

---

## 11. Test matrix

### 11.1 Devices (simulator or physical)

| Device | Orientations | Priority |
|--------|--------------|----------|
| iPhone 15/16/17 (6.1") | Portrait + landscape | P0 |
| iPad Pro 11" or 13" | Portrait + landscape | P0 |
| iPhone SE 3rd gen (small) | Portrait | P1 |
| iPad mini | Portrait | P2 |

### 11.2 Scenarios (each device × orientation where marked)

| # | Scenario | Pass criteria |
|---|----------|---------------|
| 1 | Fresh onboarding complete | No clipped footer; copy correct |
| 2 | Load sample league | Tournament appears; cell readable |
| 3 | Tournament detail → Attendance | Confirm Attendance fully visible, tappable |
| 4 | Confirm → Pods → Generate | Sticky bar visible; toast not permanent |
| 5 | Score 1 pod (4 players, placements) | Placement picker usable; no horizontal clip |
| 6 | Finish round 1 | Alert + toast; round advances |
| 7 | Stats with data | Section picker works; charts visible |
| 8 | Settings → welcome tour | Onboarding presents correctly on iPad |
| 9 | Dynamic Type AXL | Tournament detail: scroll reaches all actions |
| 10 | Reduce Motion on | Splash + onboarding transitions acceptable |

### 11.3 Automated tests (add / extend)

| Test | Location | Phase |
|------|----------|-------|
| Landscape tournaments smoke | `TournamentsScreenTests` | Exists — extend hittability on Add |
| Landscape stats smoke | `StatsScreenTests` | Exists |
| iPad snapshot — tournaments | `ScreenSnapshotTests` | P1 — layout `.device(config: .iPadPro12_9)` |
| iPad snapshot — tournament detail | `ScreenSnapshotTests` | P1 |
| iPhone landscape — pods sticky bar | `ScreenSnapshotTests` | P0 — fixed 844×390 |
| UI test — tournament detail landscape | New in `TournamentsScreenTests` or flow test | P1 |

---

## 12. Acceptance criteria (1.0 TestFlight)

All **Required** items in §6 satisfied on P0 device matrix (§11.1).

Sign-off recorded in [1.0-ship-checklist.md](../docs/release/1.0-ship-checklist.md) iPad section.

**Known acceptable limitations** (document in TestFlight notes):

- iPad uses centered phone layout, not split view
- Tab bar remains top-floating on iPad
- Multitasking resize not formally tested

---

## 13. Related documents

| Doc | Update when |
|-----|-------------|
| [docs/release/todo.md](../docs/release/todo.md) | Phase tasks |
| [docs/release/1.0-ship-checklist.md](../docs/release/1.0-ship-checklist.md) | QA sign-off |
| [accessibility/accessibility_todo.md](../accessibility/accessibility_todo.md) | iPad/landscape evidence |
| [docs/feature-inventory.md](../docs/feature-inventory.md) | Status → Partial → Shipped |
| [docs/ios-roadmap.md](../docs/ios-roadmap.md) | Phase tracking |
| [docs/tournament-ux-improvements.md](../docs/tournament-ux-improvements.md) | Cross-link coach mark |

---

## 14. Changelog

| Date | Change |
|------|--------|
| 2026-06-16 | Initial spec from simulator audit (iPad Pro 13", iPhone 17) |
| 2026-06-16 | Phase A–B code: `adaptiveContentWidth`, stacked pods bar, onboarding iPad wide layout |
