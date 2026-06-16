# Players

| Field | Value |
|-------|-------|
| Screen ID | `players` |
| Primary source | `Views/PlayersView.swift` |
| Core flow | No (tab) |
| Last verified | 2026-06-16 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Pass | `PlayerRow` | |
| P-1.3.1 | Pass | Player list | |
| P-1.3.2 | Untested | | |
| P-1.3.4 | Untested | | |
| P-1.4.1 | Pass | | |
| P-1.4.3 | Partial | | |
| P-1.4.4 | Partial | | |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Pass | Add player | `AccessibilityAuditTests.testPlayersScreenAccessibility` |
| O-2.5.3 | Pass | | |
| LKX-TARGET-44 | Pass | | |
| U-3.3.2 | Pass | | |
| R-4.1.2 | Partial | | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Automated accessibility audit
- [ ] VoiceOver: navigate to player detail

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-16 | Agent | Partial | `AccessibilityAuditTests.testPlayersScreenAccessibility` |
