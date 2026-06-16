# Accessibility layout plan (Dynamic Type / AXXXL)

**Last updated:** 2026-06-16  
**WCAG:** P-1.4.4 Resize Text — [criteria](../accessibility/wcag-2.1-aa/criteria.md) · Manual gate: [Manual_todo.md](../accessibility/Manual_todo.md)

Tracks layout reflow for **large accessibility text sizes** (Settings → Larger Text → AX1 through AXXXL). VoiceOver work is separate ([accessibility_todo.md](../accessibility/accessibility_todo.md)).

---

## Context

| Area | Status |
|------|--------|
| Empty states + tab clearance | Done — `adaptiveEmptyStateLayout()`, `tabBarClearance` |
| Pods sticky bar stacking | Done — `usesStackedRowLayout` |
| Segmented → menu at large text | **In progress** (this plan) |
| Row Dynamic Type caps (AX2) | Intentional — [design-system.md](design-system.md) |
| Manual AXXXL evidence | Open — `evidence/dynamic-type/` |

Automated UI audits **exclude** `.textClipped`; clipping must be caught here or in manual QA.

---

## Already adapts well

- **Empty states** — scroll + extra bottom inset at accessibility sizes (Tournaments, Players, Stats, Achievements).
- **Pods sticky bar** — vertical button stack when text is large or landscape compact height.
- **Status chips** — multiline at accessibility sizes.
- **Onboarding** — `largeText` layout branching.
- **New tournament** — `List` scroll; no fixed-height form trap.
- **VoiceOver** — progress header and standings expose full spoken labels even when visuals truncate.

---

## Problem areas (priority)

| P | Issue | Screens | Fix |
|---|-------|---------|-----|
| 1 | Segmented section tabs clip in portrait at AXXXL | Tournament detail, Stats | `usesMenuSectionPicker` + `dynamicType.isAccessibilitySize` |
| 2 | Placement picker (`1st`–`4th`) clips | Pods, Edit last round | Menu picker at accessibility sizes |
| 3 | Stats chart player picker clips | Performance Trends | Menu picker at accessibility sizes |
| 4 | Progress step labels truncate | Tournament detail header | Vertical step list at accessibility sizes |
| 5 | Standings `P:` / `A:` / `W:` line shrinks | Standings rows, week-complete sheet | Stack breakdown vertically at accessibility sizes |
| 6 | Row caps stop at AX2 while system may be AXXXL | List rows | Document; revisit post–1.0 if manual QA shows need |
| 7 | Chart legends / `StatTile` fixed height | Stats, dashboards | Manual verify; optional post–1.0 |
| 8 | Manual sign-off + screenshots | All core flows | [Manual_todo.md](../accessibility/Manual_todo.md) |

---

## Implementation phases

### Phase A — Segmented control reflow (code)

- [x] Extend `AdaptiveLayout.usesMenuSectionPicker` with `dynamicType` parameter
- [x] Tournament detail section picker — menu at accessibility sizes
- [x] Stats section picker — menu at accessibility sizes
- [x] `PlacementPicker` — menu at accessibility sizes
- [x] Stats Performance Trends player picker — menu at accessibility sizes
- [x] `TournamentProgressHeader` — vertical steps at accessibility sizes
- [x] `StandingsRow` — stacked points breakdown at accessibility sizes
- [x] Unit tests in `AdaptiveLayoutTests`

### Phase B — Manual verification (human)

Automated guardrails: `AccessibilityAuditTests.testAXXXLTournamentDetailTextNotClipped` and `testAXXXLStatsTextNotClipped` (`.textClipped` at `UI-Testing-Accessibility`).

- [ ] New tournament — all fields + Create reachable at AXXXL
- [ ] Tournament detail — tabs, pods, placement, sticky actions
- [ ] Stats — segments, charts, tables scroll without overlap
- [ ] Achievements — rows do not overlap
- [ ] iPhone landscape — section menus + stacked pods bar
- [ ] iPad portrait — tournament detail + stats
- [ ] Attach screenshots to `accessibility/wcag-2.1-aa/evidence/dynamic-type/`
- [ ] Tick [Manual_todo.md](../accessibility/Manual_todo.md) and update screen verification logs

### Phase C — Optional follow-ups (post–1.0)

- [ ] Raise or remove AX2 caps on rows if Phase B shows unreadable text at AXXXL
- [ ] `StatTile` / chart legend reflow
- [x] Dedicated AXXXL UI tests with `.textClipped` (`AccessibilityAuditTests` + `UI-Testing-Accessibility`)

---

## Test hooks

| Hook | Purpose |
|------|---------|
| `UI-Testing-Accessibility` launch arg | Forces `.accessibility5` on app shell ([ContentView.swift](../BudgetLeagueTracker/ContentView.swift)) |
| `AdaptiveLayoutTests` | Stacked row + menu picker predicates |
| Component snapshots | Default Dynamic Type; re-record if picker chrome changes |

---

## See also

- [polish-plan.md](polish-plan.md) — Sprint 6 manual a11y
- [ipad-layout-plan.md](ipad-layout-plan.md) — landscape / iPad reflow
- [design-system.md](design-system.md) — AX2 row caps
- [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) §5.2
