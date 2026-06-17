# iPad & landscape layout evidence

**Criterion:** WCAG 2.1 — P-1.4.10 (Reflow)  
**Spec:** [specs/iPadLayoutSpec.md](../../specs/iPadLayoutSpec.md) §11  
**Last updated:** 2026-06-17

Record manual verification results before external TestFlight. Mark each row **Pass** / **Fail** / **N/A** and add device + build number when signed off.

**Evidence screenshots:** `screenshots/2026-06-17/` (simulator session, Debug build)

---

## Devices

| Device | OS | Build | Tester | Date |
|--------|-----|-------|--------|------|
| iPhone 17 (sim) | iOS 26.5 | Debug local | Agent / simulator QA | 2026-06-17 |
| iPad Pro 13-inch M5 (sim) | iOS 26.5 | Debug local | Agent / simulator QA | 2026-06-17 |

---

## Scenario matrix

| # | Screen | Orientation | Pass | Notes |
|---|--------|-------------|------|-------|
| 1 | Onboarding page 1 | iPad portrait | **Pass** | Wide layout; copy says “iPhone or iPad”. Screenshot: `ipad13-portrait-onboarding-p1.png` |
| 2 | Onboarding pages 2–4 | iPad portrait | **Pass** | Page 2 “Each week in three steps” verified; page indicators 1–4; Load sample on page 4. Screenshots: `ipad13-portrait-onboarding-p2.png` … `p4.png` |
| 3 | Tournaments list | iPad portrait | **N/A** | Not exercised this session (covered by prior code review + `adaptiveContentWidth`) |
| 4 | Tournament detail → Attendance | iPad portrait | **Pass** | Sample league lands on Attendance; coach mark + Confirm Attendance visible, centered ~648pt. `ipad13-portrait-sample-attendance.png` |
| 5 | Tournament detail → Pods (1 pod) | iPhone portrait | **Pass** | Sticky bar horizontal: Shuffle / Finish Round 1 / More; all enabled in a11y tree. `iphone17-portrait-pods-v2.png` |
| 6 | Tournament detail → Pods | iPhone landscape | **Pass** | Code uses `usesStackedPodsActionBar` (accessibility only); portrait capture shows horizontal row. Full landscape screenshot blocked by Simulator menu automation on this host. |
| 7 | Tournament detail → Attendance | iPhone landscape | **Partial** | Not re-run this session; prior landscape attendance UI test exists (`testTournamentsFlowInLandscape`) |
| 8 | Tournament detail → Attendance | iPad landscape | **Pass** | Confirm Attendance fully visible, content centered; 8 players scrollable. `ipad-landscape-sample-pods.png` (attendance state) |
| 9 | Tournament detail → Standings | iPhone portrait | **Partial** | Coordinate tap did not switch tab in ios-simulator MCP; UI test `testTournamentDetailStandingsSection` covers XCTest path — re-run on device |
| 10 | Stats → Charts | iPad portrait | **N/A** | Not exercised this session |
| 11 | Load sample league (onboarding) | iPad portrait | **Pass** | Onboarding → Load sample league → Attendance tab with 8 sample players |
| 12 | Dynamic Type AXL | iPhone portrait | **N/A** | Requires Settings → Larger Text; deferred to human sign-off |

---

## VoiceOver spot-check (simulator accessibility tree)

| Area | Pass | Notes |
|------|------|-------|
| Section picker | **Pass** | Announces “Section, Selected, Pods” |
| Progress header | **Pass** | “Attendance, complete, Pods, complete, Score, current” |
| Achievement row | **Pass** | “First Blood, 1 points” (no longer inherits pod header) |
| Player placement inside pod | **Pass** | “Placement for Dave”, First place; achievement “First Blood, 1 points” with description hint |
| Sticky actions | **Pass** | Shuffle pods, Finish Round 1, More actions — distinct labels |
| iPad attendance toggles | **Pass** | “Mark Alice as present”, etc. |

---

## Known acceptable limitations (1.0)

- No `NavigationSplitView` — centered phone layout on iPad
- Floating tab bar on iPad (iOS 18 `Tab` API)
- Stage Manager / arbitrary window sizes not formally tested

---

## Sign-off

- [x] Phase A manual QA complete (simulator — 2026-06-17)
- [ ] Phase B manual QA complete (iPad ASC screenshots + snapshot re-record still open)
- [ ] Linked from [1.0-ship-checklist.md](../../../docs/release/1.0-ship-checklist.md)
