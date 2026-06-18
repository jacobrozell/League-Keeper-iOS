# UX & accessibility audit — fresh install, VoiceOver, large text

**Date:** 2026-06-18  
**Method:** Simulator walkthrough (fresh install → sample league → attendance → round → scoring), codebase review, WCAG tracker cross-check  
**Personas:** New MTG player (never ran a tournament); VoiceOver user; near-blind user with AXXXL Dynamic Type  
**Overall:** Core flow is usable but jargon-heavy and several a11y gaps block confident self-serve hosting.

**Tracker:** Per-screen WCAG checklists in [`../wcag-2.1-aa/screens/`](../wcag-2.1-aa/screens/) · Manual gate: [`../Manual_todo.md`](../Manual_todo.md)

---

## Executive summary

| Persona | Verdict | Top blocker |
|---------|---------|-------------|
| New MTG host | Partial | Domain jargon (Bracket, TCGPlayer, “the 99”, pod/table); attendance looked “done” before action |
| VoiceOver | Partial | Achievement descriptions missing in scoring toggles; coach marks silent |
| Near-blind + AXXXL | Partial | List row text capped below system size; chrome-heavy screens |

**Fixes landed 2026-06-18:** attendance defaults absent; coach mark announcements; achievement VO hints in `TableBonusesSection`; row Dynamic Type cap raised to AXXXL; `StatTile` reflow; toolbar text labels at large text; house rules plain-language intro.

---

## Critical — likely to abandon or mis-score

| ID | Finding | Screens | WCAG | Status |
|----|---------|---------|------|--------|
| C-01 | House rules reference TCGPlayer/Moxfield, Bracket 2, “the 99” without plain-language intro | `tournament-detail`, rules sheet | U-3.3.2 | **Partial** — intro + glossary + plain summary lines |
| C-02 | Achievement names in round scoring lack descriptions in UI + VoiceOver | `tournament-detail` (round) | P-1.1.1, R-4.1.2 | **Fixed** (`TableBonusesSection`) |
| C-03 | Attendance defaulted all players **present** — looked confirmed before host acted | `attendance` | U-3.3.2 | **Fixed** |
| C-04 | Onboarding page 4: three competing CTAs; jargon on pages 1–3 | `onboarding` | U-3.3.2 | **Partial** — copy + CTA hierarchy |
| C-05 | Week vs round vs table vs pod unclear in nav titles and copy | `attendance`, `tournament-detail` | U-3.3.2 | **Partial** — round labels, step names, hints |

---

## High — friction and errors

| ID | Finding | Screens | WCAG | Status |
|----|---------|---------|------|--------|
| H-01 | Coach marks visible only; no VoiceOver announcement | `attendance`, round | P-1.1.1, O-2.4.3 | **Fixed** |
| H-02 | List rows cap text at AX2 while system may be AXXXL | `_shared-components` | P-1.4.4 | **Fixed** (cap → AX5) |
| H-03 | `StatTile` shrinks values via `minimumScaleFactor` at large text | `stats`, dashboards | P-1.4.4 | **Fixed** |
| H-04 | Toolbar House Rules / Table Display icon-only at large text | `tournament-detail` | O-2.4.4, P-1.1.1 | **Fixed** |
| H-05 | Duplicate “Seat Players” entry points | `tournament-detail` | O-2.4.4 | **Fixed** — sticky bar only in empty seating |
| H-06 | Nav title “Attendance – Week 1” hides tournament name | `attendance` | P-1.3.2 | **Fixed** — embedded vs standalone navigation |
| H-07 | Tournament list subtitle dense (week, round, players, achievements) | `tournaments` | P-1.4.4 | **Fixed** — simplified subtitle |
| H-08 | Manual AXXXL + VoiceOver sign-off not completed | All core | P-1.4.4, P-1.3.2 | Open |
| H-09 | Increase Contrast not verified on parchment / gold tokens | Global | P-1.4.3, LKX-CONTRAST-MODES | Open |
| H-10 | iPhone landscape two-column layout broke app | Global | P-1.3.4 | **Fixed** (prior session) |

---

## Medium — polish and comprehension

| ID | Finding | Screens | Status |
|----|---------|---------|--------|
| M-01 | Achievement preview rows: description visible but VO hint missing | Round preview | **Fixed** (RoundFlowView hints) |
| M-02 | Progress header + sticky bar + tab bar = minimal content at AXXXL | `tournament-detail` | **Partial** — collapsible progress steps |
| M-03 | “Mark all” / “Clear all” footer easy to miss below toggles | `attendance` | Open |
| M-04 | Stats charts readable visually only; VO summaries partial | `stats` | Partial |
| M-05 | Empty state copy assumes league vocabulary | `tournaments`, onboarding | Open |
| M-06 | Redundant rules subtitle on tournament detail | `tournament-detail` | **Fixed** (prior session) |
| M-07 | Light mode toggle ignored at root | Global | **Fixed** (prior session) |

---

## Persona notes

### New MTG player (sighted)

- Sample league path works; confusion peaks at **house rules** and **first scoring week**.
- “Seat Players” and “tables of four” need one-line plain-language helper.
- Recommend: glossary links, coach copy rewrite, attendance “0 of N present” default.

### VoiceOver

- Section picker announces selection well (“Selected, Round”).
- Placement toggles labeled per player; pod headers separate.
- Gaps: achievement hints in scoring, coach mark announcements, inconsistent “Start Scoring” labels.
- See [`../Manual_todo.md`](../Manual_todo.md) for device sign-off checklist.

### Near-blind + AXXXL (may not use VoiceOver)

- Structural reflow (menu pickers, stacked sticky bars, scrollable empty states) is solid.
- **Text caps** were the main betrayal of system text size — addressed in shared rows.
- `StatTile` and chart legends still need manual AXXXL screenshots.
- Icon-only toolbar items hurt users who don’t enable VoiceOver.

---

## Recommended fix order (remaining)

1. Manual AXXXL evidence on core screens (`evidence/dynamic-type/`)
2. Manual VoiceOver core flow (`Manual_todo.md`)
3. Increase Contrast matrix on light parchment
4. Optional: rename Round tab to clearer label (watch UI test identifiers)

---

## Evidence

| Artifact | Location |
|----------|----------|
| iPad onboarding / attendance screenshots | `evidence/layout/screenshots/2026-06-17/` |
| Landscape layout notes | `evidence/layout/ipad-landscape-2026-06-16.md` |
| Contrast token audit | `wcag-2.1-aa/evidence/contrast/semantic-colors-2026-06-16.md` |
| AXXXL screenshots (pending) | `wcag-2.1-aa/evidence/dynamic-type/` |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-06-18 | Initial multi-persona audit; P0 code fixes for attendance, coach marks, achievements, Dynamic Type caps |
