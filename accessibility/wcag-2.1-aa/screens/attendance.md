# Attendance

| Field | Value |
|-------|-------|
| Screen ID | `attendance` |
| Primary source | `Views/AttendanceView.swift` |
| Core flow | Yes (embedded in tournament detail) |
| Last verified | 2026-06-18 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Pass | Player toggles; coach mark announces via `AppAccessibility` | audit H-01 |
| P-1.3.1 | Pass | List of players; present count in header | |
| P-1.3.2 | Partial | Nav title omits tournament name | audit H-06 |
| P-1.3.4 | Pass | iPad landscape verified | `evidence/layout/` |
| P-1.4.1 | Pass | Toggle on/off state | |
| P-1.4.3 | Partial | | |
| P-1.4.4 | Partial | `PlayerRow` scales to AXXXL; manual verify | audit H-02 |
| O-2.4.3 | Partial | Coach mark announced on appear | audit H-01 |
| O-2.4.4 | Pass | Confirm attendance CTA; Mark all / Clear all | |
| O-2.5.3 | Pass | Toggle labels match visible name | |
| LKX-TARGET-44 | Pass | Confirm button ≥ 44pt | |
| U-3.3.2 | Pass | Default absent + footer hint when none present | audit C-03 |
| R-4.1.2 | Partial | Toggle labels + identifiers | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Default players **absent** until host marks present (2026-06-18)
- [x] Coach mark VoiceOver announcement (2026-06-18)
- [ ] Nav title include tournament name or breadcrumb
- [ ] VoiceOver: mark absent/present per player (device sign-off)
- [ ] AXXXL screenshot evidence
- [ ] UI test: attendance sheet accessibility audit

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | Code review |
| 2026-06-18 | Agent | Partial | UX audit; attendance default + coach mark fixes |
