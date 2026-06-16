# Tournament detail

| Field | Value |
|-------|-------|
| Screen ID | `tournament-detail` |
| Primary source | `Views/TournamentDetailView.swift` |
| Core flow | Yes |
| Last verified | 2026-06-16 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Partial | Standings rows; pod placement UI | |
| P-1.3.1 | Partial | Tab picker (Attendance / Pods / Standings) | |
| P-1.3.2 | Untested | Complex multi-tab layout | |
| P-1.3.4 | Untested | | |
| P-1.4.1 | Pass | Placement picker uses numbers | |
| P-1.4.3 | Partial | Semantic colors on standings | |
| P-1.4.4 | Partial | Scroll views; verify AXXXL | |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Partial | Week advance, edit round actions | |
| O-2.5.3 | Partial | | |
| LKX-TARGET-44 | Partial | Verify pod placement controls | |
| U-3.3.2 | Pass | Section headers for weeks/pods | |
| R-4.1.2 | Partial | `PlacementPicker`; tab bar needs IDs | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [ ] Accessibility identifiers on segment/tab controls
- [ ] VoiceOver: week navigation and pod placement flow
- [ ] VoiceOver: edit last round sheet entry
- [ ] Automated audit test for tournament detail (requires seed data)

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | Code review; no dedicated UI audit yet |
