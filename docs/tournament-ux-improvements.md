# Tournament UX improvements

**Last updated:** 2026-06-16  
**Perspective:** Host running a local tournament at the table.

This document captures UX review findings and a phased implementation plan. Sprints 1–3 are complete.

---

## What works today

- Tournament list: ongoing vs completed, week progress, player count, active chip
- Segmented Attendance / Pods / Standings on tournament detail
- Auto-save on placements and achievements (no per-pod save button)
- Design system identity (serif headings, gold accents, `StatTile`, `StatusChip`)

---

## Critical issues

### 1. Confirm Attendance hidden behind tab bar

The primary CTA sits below the tab bar when attendance is embedded in tournament detail. **Fix:** pin with `.safeAreaInset(edge: .bottom)`.

**Status:** Done (Sprint 1)

### 2. Wrong tab after attendance is confirmed

Reopening a tournament lands on Attendance even when attendance is already done. **Fix:** route to Pods when `presentPlayerIds` is non-empty.

**Status:** Done (Sprint 1)

### 3. Next Round always enabled

Hosts can advance without generating pods. **Fix:** disable until pods/placements exist; confirm before advancing.

**Status:** Done (Sprint 1)

---

## High-impact workflow (Sprint 2)

### 4. “What’s next?” progress header

Replace minimal info bar with step indicator: Attendance → Generate Pods → Score Round → (×3) → Week Standings → Next week.

**Status:** Done (Sprint 2) — `TournamentProgressHeader`

### 5. Live weekly standings on Pods tab

Restore inline week leaderboard from deprecated `PodsView` using `weeklyStandings` on `TournamentDetailViewModel`.

**Status:** Done (Sprint 2)

### 6. Surface this week’s achievements

Card on Pods tab listing active achievements before scoring.

**Status:** Done (Sprint 2)

### 7. Less overwhelming pod scoring

Options: one-pod-at-a-time pager, collapsible pod sections, or tap-player sheet.

**Status:** Done (Sprint 2) — collapsible pod sections in Sprint 3

### 8. Contextual action labels

| Current | Better |
|---------|--------|
| Generate | Generate Round N Pods |
| Next Round | Finish Round N |
| (after round 3) | End Week & Show Standings |

**Status:** Done (Sprint 2)

### 9. Attendance quick actions

Present count (“4 of 8”), Mark all / Clear all, read-only summary when already confirmed.

**Status:** Done (Sprint 2)

### 10. Milestone moments

Weekly standings sheet after round 3; emphasize winner at tournament completion.

**Status:** Done (Sprint 2) — week-complete sheet; champion header on completed detail in Sprint 3

---

## Polish (Sprint 3)

| Area | Suggestion | Status |
|------|------------|--------|
| Haptics | Confirm Attendance, Generate, Finish Round | Done |
| Toasts | “Round 1 saved”, “Week 2 started” | Done |
| Empty states | Primary CTA inside Pods empty-state card | Done (Sprint 2) |
| Tournament list | “Resume Week N”, active achievement count | Done |
| New tournament | Coach mark on first attendance | Done — `CoachMarkBanner` + `AttendanceCoachMarkStore` |
| Focus mode | Hide tab bar during live tournament detail | Done |
| Placement picker | 1st / 2nd / 3rd / 4th labels | Done |
| Sticky actions | Pin Generate + Finish Round while scrolling pods | Done |
| Collapsible pods | Expand one pod at a time while scoring | Done |

---

## Flow gap vs `user-flows.md`

`user-flows.md` describes a dedicated **Weekly Standings** screen with Continue / Exit after round 3. That flow was folded into the Standings tab without a guided week-end moment. `LeagueEngine.closeWeeklyStandings` still exists — consider a lightweight “Week complete” sheet.

---

## Implementation phases

| Sprint | Scope | Status |
|--------|-------|--------|
| **1** | Tab bar CTA fix, smart tab routing, Next Round guard + confirm | Done (2026-06-16) |
| **2** | Progress header, weekly standings on Pods, achievements card, contextual labels, week-complete sheet | Done (2026-06-16) |
| **3** | Collapsible pods, haptics, toasts, sticky actions, placement labels, focus mode, list subtitles, champion header | Done (2026-06-16) |

---

## Verification

- Manual: run a week on simulator — Confirm Attendance reachable, lands on Pods after confirm, cannot advance without pods
- Unit: `TournamentDetailViewModelTests` for `canNextRound`, tab routing, button titles
- UI: existing `WeeklyRoundFlowTests` / tournament detail tests

---

## Next: 1.0 polish (sprints 4–6)

Follow-up work (share standings, undo clarity, second coach mark, week celebration, settings links, a11y sign-off) is tracked in **[polish-plan.md](polish-plan.md)**.
