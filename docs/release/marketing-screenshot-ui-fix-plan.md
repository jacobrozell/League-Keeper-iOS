# Marketing screenshot & UI fix plan

**Status:** In progress (Phase 1–4 implemented 2026-06-19)  
**Created:** 2026-06-19  
**Trigger:** Audit of `marketing-screenshots/asc/2026-06-19/` found duplicate captures, iPad rotation bugs, AXXXL layout breaks, and contrast/hierarchy issues.

---

## Goals

1. **Reliable captures** — each numbered marketing PNG shows the intended screen (tournaments list, round, standings, stats, achievements, settings, onboarding).
2. **Marketing-ready data** — sample league name and populated standings/stats, not “UI Test League” debug copy.
3. **Accessibility layouts** — AXXXL (`.accessibility5`) must not truncate, overlap, or break picker labels.
4. **Visual polish** — contrast, redundant chrome, and brand consistency suitable for App Store screenshots.

---

## Issues summary

| Category | Examples |
|----------|----------|
| Capture pipeline | Shots 01–06 identical; tab taps fail while tab bar hidden in tournament detail; iPad PNGs rotated 90°/180° |
| AXXXL layout | “Show progress st…”, “Rou/nd” picker wrap, attendance header overlap, sticky footer over list content |
| Contrast | Achievement descriptions (`.tertiary`), disabled primary buttons, dark-mode card subtext |
| Hierarchy | “Round 1 of 3” twice; achievements block above primary seating task |
| Branding | Serif empty-state titles vs sans-serif app; onboarding blue Continue vs gold accent; “Seat Tables” vs “Seat Players” |

---

## Phase 1 — Capture pipeline (P0)

**Problem:** `capture-evidence-pack.sh` navigates via idb taps after a single launch. Back/section/tab taps fail silently (`|| true`), and main tabs are hidden inside tournament detail.

**Approach:** Deterministic **snapshot launch arguments** — relaunch the app per screenshot with seeded state.

| Launch arg | Result |
|------------|--------|
| `UI-Testing-Marketing-Seed` | Load `DemoLeagueLoader` + mid-week scored data |
| `UI-Testing-Snapshot-TournamentsList` | Tournaments tab, list visible |
| `UI-Testing-Snapshot-DetailRound` | Open sample tournament → Round tab |
| `UI-Testing-Snapshot-DetailStandings` | Open sample tournament → Standings tab |
| `UI-Testing-Snapshot-TabStats` | Stats tab with data |
| `UI-Testing-Snapshot-TabAchievements` | Achievements tab |
| `UI-Testing-Snapshot-TabSettings` | Settings tab |
| `UI-Testing-Snapshot-DetailAttendance` | Attendance tab (existing seed) |
| `UI-Testing-Onboarding` | First onboarding page (unchanged) |

**Script changes (`capture-evidence-pack.sh`):**

- Replace tap-based flow with `launch_app` + `shot` per filename.
- Fix orientation helper: activate Simulator, normalize to portrait, then rotate once for landscape; add settle delay before screenshot.
- Keep attendance/onboarding/dark/AXXXL matrix; wire AXXXL shots to same snapshot args.

**Acceptance:**

- [ ] `01-tournaments` ≠ `02-round` ≠ `03-standings` visually
- [ ] `04-stats`, `05-achievements`, `06-settings` show correct tabs
- [ ] iPad portrait/landscape screenshots align with status bar
- [ ] Tournament title reads **“Weekly Game Night”** (demo league)

---

## Phase 2 — AXXXL layout (P0)

| Area | Fix |
|------|-----|
| `AdaptiveSidebarLayout` | Stack sidebar above main on iPad at accessibility text sizes; proportional sidebar width at default iPad sizes |
| `TournamentProgressHeader` | Full-width toggle text (wrap, no truncation); hide dot row when week/round labels already visible at default size only |
| Section menu pickers (`TournamentDetailView`, `StatsView`, standings week picker) | Full-width stacked rows at accessibility sizes; prevent narrow menu value columns |
| `AttendanceView` | Inline navigation title at AXXXL; move “Who’s playing?” actions out of cramped section header |
| `RoundSeatingView` / `RoundFlowView` | Bottom scroll content inset so sticky “Seat Players” bar does not cover achievements |
| `AdaptiveLayout` | Tab-bar / sticky-bar clearance constants for `.accessibility5` |

**Acceptance:**

- [ ] AXXXL round portrait: no truncated “Show progress…”, no “Rou/nd”
- [ ] AXXXL attendance portrait: no overlapping header controls
- [ ] AXXXL round landscape: list content clears sticky footer

---

## Phase 3 — Contrast & readability (P1)

| Area | Fix |
|------|-----|
| `AchievementDescriptionText` (`.compact`) | `.secondary` instead of `.tertiary` |
| `PrimaryActionButton` disabled | Visible label (secondary ink on muted fill), not near-white on pale gray |
| `TournamentProgressHeader` upcoming steps | `.secondary` minimum for step labels |
| Attendance footer hint | `.secondary` at caption weight |

**Acceptance:**

- [ ] Dark-mode achievement descriptions readable on card background
- [ ] Disabled “Confirm Attendance” clearly legible

---

## Phase 4 — Hierarchy & brand (P1)

| Area | Fix |
|------|-----|
| `TournamentProgressHeader` | Remove duplicate round dots when `roundLabel` already includes round count (default sizes) |
| `TournamentDetailViewModel` | Rename step **“Seat Tables”** → **“Seat Players”** |
| `EmptyStateView` | Sans-serif title (match app typography) |
| `OnboardingView` | Gold/accent tint on prominent buttons; tighten vertical spacing on page 1 |
| Round seating (optional follow-up) | Collapse achievements preview at default phone size when empty-state is primary — defer if scope-heavy |

**Acceptance:**

- [ ] Single “Round X of Y” at default Dynamic Type on round screen
- [ ] Onboarding Continue matches accent gold
- [ ] Empty states use sans-serif headlines

---

## Phase 5 — Verification & regen

1. Unit tests: `AdaptiveLayoutTests`, `TournamentDetailViewModelTests` (progress step title), snapshot tests if layouts shift.
2. Re-run capture matrix:
   ```bash
   DATE_TAG=2026-06-19 ./Scripts/capture-evidence-pack.sh
   DATE_TAG=2026-06-19 ./Scripts/app-store-screenshot-size.sh
   ```
3. Manual spot-check ASC folder before upload.

---

## Implementation order

1. Phase 1 (snapshot args + capture script) — unblocks marketing regen  
2. Phase 2 (AXXXL) — WCAG evidence  
3. Phase 3 + 4 (contrast + brand) — quick wins in same PR  
4. Phase 5 — regen + review  

---

## Out of scope (this pass)

- Device bezel framing for website/press
- Dark-mode marketing matrix expansion beyond existing dark portrait flow
- Collapsing achievements on round screen (track as follow-up if still cluttered after header dedupe)

---

## References

- [marketing-screenshots-plan.md](./marketing-screenshots-plan.md) — original automation spec  
- [marketing-screenshots/README.md](../../marketing-screenshots/README.md) — output folders  
- Audit conversation: 2026-06-19 marketing screenshot review
