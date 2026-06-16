# New tournament

| Field | Value |
|-------|-------|
| Screen ID | `new-tournament` |
| Primary source | `Views/NewTournamentView.swift` |
| Core flow | Yes |
| Last verified | 2026-06-16 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Pass | Form controls | |
| P-1.3.1 | Pass | Grouped form sections | |
| P-1.3.2 | Untested | | |
| P-1.3.4 | Untested | | |
| P-1.4.1 | Pass | | |
| P-1.4.3 | Partial | | |
| P-1.4.4 | Partial | Steppers + text fields | |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Pass | Submit, player toggles | `AccessibilityAuditTests.testFormFieldsAccessibility` |
| O-2.5.3 | Pass | Field placeholders as labels | |
| LKX-TARGET-44 | Partial | System steppers may be < 44pt | |
| U-3.3.2 | Pass | `LabeledStepper`, name field placeholder | |
| R-4.1.2 | Pass | Toggles `toggle-*` IDs; stepper labels | `AccessibilityAuditTests` |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Automated accessibility audit on new tournament sheet
- [x] Form field label audit
- [ ] VoiceOver: player selection toggles in long list
- [ ] AXXXL: form scroll and submit reachability

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | `AccessibilityAuditTests.testNewTournamentScreenAccessibility` |
