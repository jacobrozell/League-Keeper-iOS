# iPad & landscape layout evidence

**Criterion:** WCAG 2.1 — P-1.4.10 (Reflow)  
**Spec:** [specs/iPadLayoutSpec.md](../../specs/iPadLayoutSpec.md) §11  
**Last updated:** 2026-06-16

Record manual verification results before external TestFlight. Mark each row **Pass** / **Fail** / **N/A** and add device + build number when signed off.

---

## Devices

| Device | OS | Build | Tester | Date |
|--------|-----|-------|--------|------|
| iPhone 17 (sim or physical) | | | | |
| iPad Pro 13" (sim or physical) | | | | |

---

## Scenario matrix

| # | Screen | Orientation | Pass | Notes |
|---|--------|-------------|------|-------|
| 1 | Onboarding page 1 | iPad portrait | | Wide layout; copy mentions iPhone/iPad |
| 2 | Tournaments list | iPad portrait | | Content centered ~680pt |
| 3 | Tournament detail → Attendance | iPad portrait | | Coach mark visible; Confirm not clipped |
| 4 | Tournament detail → Pods (empty) | iPhone landscape | | Sticky actions stacked; all tappable |
| 5 | Tournament detail → Pods (1 pod) | iPhone landscape | | Placement picker usable |
| 6 | Tournament detail → Attendance | iPhone landscape | | Confirm Attendance not clipped |
| 7 | Stats → Charts | iPad portrait | | Charts within readable width |
| 8 | Stats section picker | iPhone landscape | | Menu picker works |
| 9 | Load sample league (onboarding) | iPad portrait | | Lands on tournament Attendance tab |
| 10 | Dynamic Type AXL | iPhone portrait | | Tournament detail scrolls to actions |

---

## Known acceptable limitations (1.0)

- No `NavigationSplitView` — centered phone layout on iPad
- Floating tab bar on iPad (iOS 18 `Tab` API)
- Stage Manager / arbitrary window sizes not formally tested

---

## Sign-off

- [ ] Phase A manual QA complete
- [ ] Phase B manual QA complete
- [ ] Linked from [1.0-ship-checklist.md](../../../docs/release/1.0-ship-checklist.md)
