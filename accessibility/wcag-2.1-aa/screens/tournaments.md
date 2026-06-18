# Tournaments

| Field | Value |
|-------|-------|
| Screen ID | `tournaments` |
| Primary source | `Views/TournamentsView.swift` |
| Core flow | Yes |
| Last verified | 2026-06-18 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Pass | List cells + empty state CTA | |
| P-1.3.1 | Pass | `List` with sections (ongoing/completed) | |
| P-1.3.2 | Untested | | |
| P-1.3.4 | Partial | Landscape UI test | `TournamentsScreenTests` |
| P-1.4.1 | Pass | Status badges use text | |
| P-1.4.3 | Partial | Semantic list colors | `WCAGContrastTests` |
| P-1.4.4 | Partial | `TournamentCell` scales to AXXXL; subtitle dense | audit H-07 |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Pass | Create Tournament, Add toolbar | `AccessibilityAuditTests` |
| O-2.5.3 | Pass | | |
| LKX-TARGET-44 | Pass | Empty-state CTA uses `PrimaryActionButton` | |
| U-3.3.2 | Pass | Empty state hint text | |
| R-4.1.2 | Pass | `TournamentCell` identifiers for ongoing/completed rows | |
| LKX-CONTRAST-MODES | Partial | Light/dark UI tests | `TournamentsScreenTests` |

## Open work

- [x] Automated accessibility audit (tab screen)
- [x] Dark mode regression test
- [x] VoiceOver: ongoing vs completed section navigation
- [x] VoiceOver: swipe actions on tournament rows
- [ ] Simplify ongoing tournament subtitle at large text (audit H-07)
- [ ] AXXXL screenshot evidence

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | `AccessibilityAuditTests.testTournamentsScreenAccessibility` |
| 2026-06-18 | Agent | Partial | UX audit — dense list subtitles |
