# Tournament detail

| Field | Value |
|-------|-------|
| Screen ID | `tournament-detail` |
| Primary source | `Views/TournamentDetailView.swift`, `Views/RoundFlowView.swift` |
| Core flow | Yes |
| Last verified | 2026-06-18 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Partial | Achievement scoring hints added; house rules jargon | audit C-01, C-02 |
| P-1.3.1 | Partial | Section menu picker (Attendance / Round / Standings) | |
| P-1.3.2 | Untested | Complex multi-tab layout | audit C-05 |
| P-1.3.4 | Pass | iPhone landscape two-column fix | prior session |
| P-1.4.1 | Pass | Placement picker uses numbers | |
| P-1.4.3 | Partial | Semantic colors on standings | |
| P-1.4.4 | Partial | Menu pickers + stacked sticky bar; chrome heavy at AXXXL | audit M-02 |
| O-2.4.3 | Partial | Coach marks announce | audit H-01 |
| O-2.4.4 | Partial | Toolbar shows text labels at large text; duplicate Seat Players | audit H-04, H-05 |
| O-2.5.3 | Partial | | |
| LKX-TARGET-44 | Partial | Verify pod placement controls | |
| U-3.3.2 | Partial | Plain-language intro on rules sheet | audit C-01 partial fix |
| R-4.1.2 | Partial | `PlacementPicker`; achievement VO hints | audit C-02 |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Accessibility identifiers on section picker
- [x] VoiceOver: contextual action labels, pod expand/collapse, announcements
- [x] Achievement descriptions in scoring toggles (2026-06-18)
- [x] Toolbar House Rules / Table Display text at accessibility sizes (2026-06-18)
- [x] Remove redundant rules subtitle (prior session)
- [x] Plain-language intro on house rules sheet (2026-06-18)
- [ ] Deduplicate Seat Players entry points
- [ ] Collapsible progress header at AXXXL
- [ ] VoiceOver: manual full-flow sign-off (`Manual_todo.md`)
- [ ] AXXXL screenshot evidence

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | Code review |
| 2026-06-18 | Agent | Partial | Multi-persona audit; scoring + toolbar fixes |
