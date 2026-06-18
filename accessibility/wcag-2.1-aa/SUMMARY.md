# WCAG 2.1 AA rollup

**Last updated:** 2026-06-18  
**Overall release status:** `Not compliant` — P0 code fixes landed; **manual VoiceOver + AXXXL** still required ([`Manual_todo.md`](../Manual_todo.md)).  
**Latest audit:** [2026-06-18 UX & accessibility](../audits/2026-06-18-ux-accessibility-audit.md)

## Screen status

| Screen | Required criteria | Pass | Partial | Fail | Untested | Screen status |
|--------|-------------------|------|---------|------|----------|---------------|
| [onboarding](screens/onboarding.md) | 12 | 3 | 8 | 1 | 0 | Partial |
| [tournaments](screens/tournaments.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [tournament-detail](screens/tournament-detail.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [new-tournament](screens/new-tournament.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [add-players](screens/add-players.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [attendance](screens/attendance.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [edit-last-round](screens/edit-last-round.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [tournament-standings](screens/tournament-standings.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [players](screens/players.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [player-detail](screens/player-detail.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [stats](screens/stats.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [achievements](screens/achievements.md) | 12 | 4 | 6 | 0 | 2 | Partial |
| [new-achievement](screens/new-achievement.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [edit-tournament](screens/edit-tournament.md) | 12 | 3 | 7 | 0 | 2 | Partial |
| [settings](screens/settings.md) | 12 | 5 | 5 | 0 | 2 | Partial |
| [_shared-components](screens/_shared-components.md) | 8 | 4 | 4 | 0 | 0 | Partial |

*Onboarding added 2026-06-18. Attendance + shared rows improved; manual evidence still open.*

## Criterion hotspots (fix once, help many screens)

| Criterion ID | Global status | Primary fix |
|--------------|---------------|-------------|
| P-1.1.1 / LKX-CHART-A11Y | Partial | Achievement hints in scoring **fixed**; chart VO spot-check open |
| P-1.3.2 / O-2.4.3 | Untested | Manual VoiceOver pass on core flow |
| P-1.4.4 | Partial | Row caps raised to AXXXL **fixed**; manual screenshots open |
| P-1.4.10 | Partial | iPhone landscape layout **fixed**; stats charts untested |
| U-3.3.2 | Partial | Onboarding + house rules plain language **open** |
| LKX-A11Y-IDS | Partial | Tab/section identifiers + contextual host-action labels |
| LKX-CONTRAST-MODES | Partial | Increase Contrast on parchment **open** |

## Evidence checklist (release / TestFlight)

- [ ] VoiceOver — core tournament flow (`accessibility/Manual_todo.md`)
- [ ] Dynamic Type — AXXXL on new tournament, tournament detail, stats, onboarding
- [ ] Contrast — semantic token audit + Increase Contrast pass
- [ ] Orientation — portrait + landscape on tournaments and tournament detail
- [ ] Reduce Motion — verify no essential info in motion-only UI

## Changelog

| Date | Change |
|------|--------|
| 2026-06-16 | Initial tracker from codebase + UI test audit |
| 2026-06-16 | VoiceOver: announcements, contextual host actions, section picker values, pod expand labels |
| 2026-06-18 | Multi-persona UX audit; onboarding screen; attendance default absent; coach mark VO; AX5 row caps; achievement hints |
