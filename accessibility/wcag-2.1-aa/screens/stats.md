# Stats

| Field | Value |
|-------|-------|
| Screen ID | `stats` |
| Primary source | `Views/StatsView.swift` |
| Core flow | No (tab) |
| Last verified | 2026-06-18 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Partial | Charts lack full VO summaries | `LKX-CHART-A11Y` |
| P-1.3.1 | Pass | Segmented sections | |
| P-1.3.2 | Untested | | |
| P-1.3.4 | Untested | Chart width in landscape | |
| P-1.4.1 | Pass | Legend uses text labels | |
| P-1.4.3 | Partial | Chart colors | |
| P-1.4.4 | Partial | Menu picker at AXXXL; `StatTile` reflow | audit H-03 |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Partial | Segmented control segments | |
| O-2.5.3 | Partial | | |
| LKX-TARGET-44 | Pass | Tab + segment controls | |
| U-3.3.2 | Pass | Empty state hint | |
| R-4.1.2 | Partial | Charts partial | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Automated accessibility audit (tab)
- [ ] Chart VoiceOver: read weekly points per player
- [x] `accessibilityIdentifier` on stats segmented picker
- [x] `StatTile` reflow at accessibility sizes (2026-06-18)
- [ ] Chart VoiceOver: device spot-check documented in `evidence/voiceover/`
- [ ] AXXXL: chart legend reflow + screenshots

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | `AccessibilityAuditTests.testStatsScreenAccessibility` |
| 2026-06-18 | Agent | Partial | StatTile reflow; chart VO open |
