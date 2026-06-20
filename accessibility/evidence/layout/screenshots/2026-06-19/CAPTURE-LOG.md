# Evidence capture log — 2026-06-19

Automated sim capture via `Scripts/capture-evidence-pack.sh`.

## Totals

| Pack | Count | Location |
|------|------:|----------|
| Layout screenshots | 69 | `accessibility/evidence/layout/screenshots/2026-06-19/` |
| AXXXL evidence | 10 | `accessibility/wcag-2.1-aa/evidence/dynamic-type/2026-06-19/` |
| Accessibility audits (JSON) | 29 | `accessibility/wcag-2.1-aa/evidence/voiceover/2026-06-19/` |
| Marketing — iPhone | 31 | `marketing-screenshots/raw/2026-06-19/` |
| Marketing — iPad | 31 | `marketing-screenshots/ipad/raw/2026-06-19/` |

## Devices

- **iPhone:** League Keeper iPhone (`68292785-6474-4C43-8CA0-AF209F379D3D`)
- **iPad:** League Keeper iPad (`96A80753-FCA0-402F-8CEA-3D06228190E6`)

## Matrix captured

Per device: light + dark (portrait), light landscape, AXXXL portrait + landscape.

Screens: tournaments list, round tab, standings, stats, achievements, settings, attendance, onboarding.

## Audit notes

- **Confirm Attendance disabled** on attendance seeds is expected (no players marked present).
- No unlabeled interactive buttons flagged in audit JSONs.
- **AXXXL review (2026-06-19):** attendance section header and menu picker rows overlapped at AXXXL — fixed via `usesStackedLabelPickerRow` in `AttendanceView`, `TournamentDetailView`, `StatsView`. Re-capture AXXXL shots after fix.
- Re-run: `DATE_TAG=2026-06-19 RUN_MODE=full ./Scripts/capture-evidence-pack.sh`
