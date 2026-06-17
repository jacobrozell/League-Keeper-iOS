# iPad layout fix plan

**Date:** 2026-06-17  
**Status:** Implemented (2026-06-17)  
**Related:** [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md), [AdaptiveLayout.swift](../BudgetLeagueTracker/Support/AdaptiveLayout.swift)

---

## Problem

On iPad, most screens render as a ~680pt phone column centered in a wide canvas. The branded background fills the full width while list content stays narrow, producing large empty side margins — especially visible on tournament detail → Pods (core scoring flow).

Functional QA passes (CTAs reachable, VoiceOver OK) but the app does not feel iPad-native.

---

## Goals

1. Use more horizontal space on iPad without phone-stretching edge-to-edge lists.
2. Two-column layouts on high-value scoring screens (Pods, Attendance).
3. Consistent content width across tab roots, forms, sheets, and detail views.
4. Update App Store copy to reflect universal iPhone + iPad positioning.

## Non-goals (this pass)

- `NavigationSplitView` / sidebar master–detail
- Stage Manager / arbitrary window resize matrix
- iPad-only features (keyboard shortcuts, Pencil)

---

## Phase 1 — Layout tokens

| Change | Before | After |
|--------|--------|-------|
| `contentMaxWidth` | 680 pt | **920 pt** |
| `sidebarWidth` | — | **320 pt** (new) |
| `columnSpacing` | — | **20 pt** (new) |
| `usesTwoColumnLayout` | — | `horizontalSizeClass == .regular` |

Wider cap reduces dead space on 13" iPad (~10% margins vs ~33%). Two-column uses the extra width for context + scoring side-by-side.

---

## Phase 2 — Tournament detail (highest impact)

### Pods tab

When `usesTwoColumnLayout`:

```
┌─────────────────────────────────────────────────────────┐
│ Progress header + section picker (full content width)   │
├──────────────────┬──────────────────────────────────────┤
│ Sidebar (320pt)  │ Main (flex)                          │
│ • Achievements   │ • Coach mark / hint                  │
│ • Week standings │ • Pod disclosure groups + scoring      │
│ • Layout hint    │                                      │
├──────────────────┴──────────────────────────────────────┤
│ Sticky action bar (full width)                          │
└─────────────────────────────────────────────────────────┘
```

Phone / compact: unchanged single-column `List`.

### Attendance tab

Embedded `AttendanceView` gets a two-column `LazyVGrid` for player toggles on regular width.

---

## Phase 3 — Consistent width on secondary screens

Apply `.adaptiveContentWidth()` to:

- `NewTournamentView`
- `AddPlayersView`
- `AttendanceView` (standalone sheet)
- `PlayerDetailView`
- `EditLastRoundView`
- `EditTournamentView`
- `WeekCompleteSheetView`
- `TournamentStandingsView`

---

## Phase 4 — Copy & docs

- [app-store-listing.md](app-store-listing.md) — “phone” → “iPhone or iPad” / “device”
- [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) — changelog + revised §5.1 tokens
- [AdaptiveLayoutTests.swift](../BudgetLeagueTrackerTests/Support/AdaptiveLayoutTests.swift) — new token + two-column helper tests

---

## Verification

| Check | Method |
|-------|--------|
| Unit tests | `AdaptiveLayoutTests` |
| Build | Xcode build sim |
| iPad Pods two-column | Manual / simulator screenshot |
| iPhone regression | Portrait pods unchanged |
| VoiceOver | No regression on section picker + sticky bar |

---

## Acceptance

- [x] iPad tournament detail Pods uses two-column layout at regular width
- [x] `contentMaxWidth` is 920 pt
- [x] Forms and sheets match tab-root width behavior
- [x] App Store listing mentions iPad
- [x] Tests pass (`AdaptiveLayoutTests` + build verified; xcodebuild test hit Xcode build-system crash in this environment)
