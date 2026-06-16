# Tournament standings

| Field | Value |
|-------|-------|
| Screen ID | `tournament-standings` |
| Primary source | `Views/TournamentStandingsView.swift` |
| Core flow | Yes |
| Last verified | 2026-06-16 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Pass | `StandingsRow` labels | |
| P-1.3.1 | Pass | Ranked list | |
| P-1.3.2 | Untested | | |
| P-1.3.4 | Untested | Full-screen cover | |
| P-1.4.1 | Pass | Rank + points text | |
| P-1.4.3 | Partial | Winner accent color | |
| P-1.4.4 | Partial | | |
| O-2.4.3 | Untested | | |
| O-2.4.4 | Pass | Close / dismiss CTA | |
| O-2.5.3 | Pass | | |
| LKX-TARGET-44 | Pass | Modal actions | |
| U-3.3.2 | Pass | | |
| R-4.1.2 | Partial | Standings rows | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [ ] VoiceOver: final standings read order (rank → name → points)
- [ ] Reduce Motion on presentation (if animated)

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
