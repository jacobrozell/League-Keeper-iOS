# 1.0 polish plan

**Last updated:** 2026-06-17  
**Perspective:** League host at the table + pre–TestFlight / App Store readiness.

Tournament host UX Sprints 1–3 are complete ([tournament-ux-improvements.md](tournament-ux-improvements.md)). This document captures the **next wave** of polish: table-side delight, trust signals, layout consistency, accessibility sign-off, and release hygiene.

---

## Context

| Area | Status |
|------|--------|
| Core tournament flow | Shipped |
| Tournament UX sprints 1–3 | Done |
| iPad layout code (Phase A–B) | Mostly done — manual QA open ([ipad-layout-plan.md](ipad-layout-plan.md)) |
| WCAG tracker | Partial — manual VoiceOver / AXXXL / landscape evidence open |
| App Store assets | Icon, screenshots, TestFlight upload open ([release/todo.md](release/todo.md)) |

---

## Ideas backlog

### At game night (highest user impact)

| # | Idea | Rationale |
|---|------|-----------|
| P1 | **Share standings** | Hosts paste weekly or final results into Discord / group chat. Data exists; no export surface yet. |
| P2 | **Clearer undo / edit-last-round** | “Edit Last Round” is easy to misread. Rename or add hint + optional confirm so hosts know it reverts the last scored pod. |
| P3 | **Generate Pods coach mark** | First-attendance coach mark ships; next confusion point is when to tap Generate. One-time tip, same pattern as `AttendanceCoachMarkStore`. |
| P4 | **Week-complete celebration** | `WeekCompleteSheetView` is functional but flat. Highlight #1, gold accent, success haptic on open — match champion header on completed tournaments. |
| P5 | **Odd roster size messaging** | When attendance ≠ multiple of 4, show inline note (“5 present — expect one pod of 3”) so hosts aren’t surprised at pod layout. |

### First impression & trust

| # | Idea | Rationale |
|---|------|-----------|
| P6 | **Settings → Support & Privacy links** | In-app links to hosted Pages URLs ([AppStoreConnectSpec.md](../specs/AppStoreConnectSpec.md)). Closes reviewer loop and helps real users. |
| P7 | **App icon 1024×1024** | Launch / splash assets exist; store icon is the biggest visual gap before TestFlight feels “real.” |
| P8 | **`adaptiveContentWidth` on Players & Achievements** | Core tabs use max-width; these two still phone-stretch on iPad. |

### Accessibility (polish for everyone)

| # | Idea | Rationale |
|---|------|-----------|
| P9 | **Chart VoiceOver summaries** | Main WCAG partial on Stats. Spoken data summary on `BarChartView` / `LineChartView` / `PieChartView`. |
| P10 | **Manual a11y sign-off** | VoiceOver core flow, AXXXL, landscape reflow — [Manual_todo.md](../accessibility/Manual_todo.md), layout work — [accessibility-layout-plan.md](accessibility-layout-plan.md). |

### Release hygiene

| # | Idea | Rationale |
|---|------|-----------|
| P11 | **iPhone landscape QA** | Pods sticky bar + attendance confirm — code landed; checkboxes open in [ipad-layout-plan.md](ipad-layout-plan.md) Phase A. |
| P12 | **iPad portrait QA** | Onboarding → sample league → attendance confirm on real iPad. |
| P13 | **Re-record snapshot baselines** | 26+ drifted after UX sprints; prevents silent visual regressions. |
| P14 | **TestFlight playthrough** | 2–3 full-season runs on physical device. |

### Post–1.0 (do not block ship)

| Idea | Notes |
|------|-------|
| iCloud backup / JSON export | [ios-roadmap.md](ios-roadmap.md) Phase 4 |
| Player search (large rosters) | Low frequency for v1 leagues |
| iPad `NavigationSplitView` sidebar | [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) Phase C |
| Widgets / Shortcuts | “Who’s leading?” glance |

---

## Implementation phases

Recommended order: **Sprint 4** (table delight) → **Sprint 5** (trust + layout) → **Sprint 6** (a11y + QA gate) in parallel with **release assets**.

### Sprint 4 — Table delight (P1–P5)

**Goal:** Hosts feel the app is *finished* during live play.

| Task | Scope | Primary files | Tests | Status |
|------|-------|---------------|-------|--------|
| **4.1 Share standings** | `ShareLink` plain-text standings on week-complete + final rankings sheets. | `StandingsShareFormatter.swift`, `WeekCompleteSheetView.swift`, `TournamentStandingsView.swift` | `StandingsShareFormatterTests` | Done |
| **4.2 Undo clarity** | Confirmation before opening edit-last-round sheet. | `TournamentDetailView.swift` | — | Done |
| **4.3 Generate Pods coach mark** | One-time tip on Pods tab when pods empty. | `GeneratePodsCoachMarkStore.swift`, `TournamentDetailView.swift`, `ContentView.swift` | `GeneratePodsCoachMarkStoreTests` | Done |
| **4.4 Week-complete celebration** | Champion header, gold accent, success haptic on sheet open. | `WeekCompleteSheetView.swift` | — | Done |
| **4.5 Odd roster messaging** | Hint when attendance ≠ multiple of 4. | `PodLayoutHint.swift`, `AttendanceView.swift`, `TournamentDetailView.swift` | `PodLayoutHintTests` | Done |

**Sprint 4 exit criteria**

- [x] Share sheet produces readable text for a completed week and final tournament
- [x] Edit-last-round action has confirmation before opening
- [x] Second coach mark shows once before first pod generation
- [x] Week-complete sheet highlights leader
- [x] Non-multiple-of-4 attendance shows explanatory copy

---

### Sprint 5 — Trust & layout consistency (P6–P8, P7)

**Goal:** App feels trustworthy and consistent on all devices before external beta.

| Task | Scope | Primary files | Tests | Status |
|------|-------|---------------|-------|--------|
| **5.1 Settings links** | Support + Privacy `Link` rows; URLs in `AppInfo`. | `AppInfo.swift`, `SettingsView.swift` | — | Done |
| **5.2 App icon** | 1024×1024 PNG in `Assets.xcassets/AppIcon.appiconset`. | Asset catalog + `Scripts/generate-launch-assets.py` | Visual / ASC upload | Done |
| **5.3 Players & Achievements max-width** | Apply `.adaptiveContentWidth()`. | `PlayersView.swift`, `AchievementsView.swift` | — | Done |

**Sprint 5 exit criteria**

- [x] Settings opens support and privacy URLs in Safari
- [x] App icon present in archive
- [x] Players and Achievements centered on iPad portrait

---

### Sprint 6 — Accessibility & QA gate (P9–P14)

**Goal:** WCAG manual evidence complete; layout verified on device; CI snapshots current.

| Task | Scope | Primary files | Tests |
|------|-------|---------------|-------|
| **6.1 Chart a11y** | `accessibilityLabel` + `accessibilityValue` with numeric summary on each chart type. | `Components/Charts/*.swift` | `WCAGContrastTests` / component tests; update `screens/stats.md` |
| **6.2 a11y identifiers** | Tournament detail tab picker + Stats segmented control IDs ([accessibility_todo.md](../accessibility/accessibility_todo.md) Phase 1). | `TournamentDetailView.swift`, `StatsView.swift` | `AccessibilityAuditTests` |
| **6.3 Manual VoiceOver pass** | Complete [Manual_todo.md](../accessibility/Manual_todo.md); link evidence in `wcag-2.1-aa/evidence/`. | Tracker markdown only | Human sign-off |
| **6.4 Landscape / iPad QA** | Phase A + B manual items in [ipad-layout-plan.md](ipad-layout-plan.md); fill [layout evidence](../accessibility/evidence/layout/ipad-landscape-2026-06-16.md). | — | Checklist in ship doc |
| **6.5 Snapshot re-record** | iPad Pro + iPhone landscape cases per ipad-layout-plan. | `ScreenSnapshotTests.swift` | CI green |
| **6.6 TestFlight** | First upload + 2–3 full-season playthroughs. | [release/testflight.md](release/testflight.md) | Beta feedback log |

**Sprint 6 exit criteria**

- [ ] `SUMMARY.md` Overall status moves toward Pass for core flow
- [ ] [1.0-ship-checklist.md](release/1.0-ship-checklist.md) accessibility + iPad sections checked *(Phase A iPad/landscape sim QA logged 2026-06-17)*
- [ ] Snapshot suite passes in CI
- [ ] Internal TestFlight build exercised end-to-end on iPhone + iPad

---

## Suggested schedule

| Week | Focus |
|------|-------|
| **1** | Sprint 4.1–4.2 (share + undo clarity) — highest table impact |
| **2** | Sprint 4.3–4.5 (coach mark, week celebration, odd roster) |
| **3** | Sprint 5 (settings links, icon, layout) + start Sprint 6.1–6.2 |
| **4** | Sprint 6.3–6.6 (manual QA, snapshots, TestFlight) |

Adjust if App Store timeline is fixed; **P7 (icon)** and **P14 (TestFlight)** can run in parallel with Sprint 4.

---

## File quick reference

| File | Sprint | Change |
|------|--------|--------|
| `Support/AppInfo.swift` | 5 | `supportURL`, `privacyURL` |
| `Views/SettingsView.swift` | 5 | Help links |
| `Views/WeekCompleteSheetView.swift` | 4 | Celebration + share |
| `Views/TournamentStandingsView.swift` | 4 | Share final standings |
| `Views/TournamentDetailView.swift` | 4 | Undo label, generate coach mark, odd-roster hint |
| `Support/Onboarding/GeneratePodsCoachMarkStore.swift` | 4 | New |
| `Support/StandingsShareFormatter.swift` | 4 | New |
| `Views/PlayersView.swift` | 5 | `adaptiveContentWidth` |
| `Views/AchievementsView.swift` | 5 | `adaptiveContentWidth` |
| `Components/Charts/*.swift` | 6 | VoiceOver summaries |
| `Assets.xcassets/AppIcon.appiconset/` | 5 | 1024 icon |

---

## Verification

- **Unit:** formatters, coach mark stores, view model copy / `canEdit`
- **UI:** share sheet smoke; settings links; landscape tournaments detail (existing suite)
- **Manual:** full week on iPhone + iPad; VoiceOver spot-check on share + week-complete
- **Release:** tick items in [1.0-ship-checklist.md](release/1.0-ship-checklist.md)

---

## Related

- [tournament-ux-improvements.md](tournament-ux-improvements.md) — prior sprints (complete)
- [ipad-layout-plan.md](ipad-layout-plan.md) — layout QA checklist
- [accessibility_todo.md](../accessibility/accessibility_todo.md) — engineering a11y backlog
- [release/todo.md](release/todo.md) — open release tasks
- [ios-roadmap.md](ios-roadmap.md) — post–1.0 features
