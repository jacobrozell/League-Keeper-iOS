# Accessibility engineering backlog

Phased work to move `wcag-2.1-aa/SUMMARY.md` from **Not compliant** to **Pass** before App Store release.

## Phase 0 — Tracker & automation (done)

- [x] WCAG 2.1 AA tracker (`accessibility/wcag-2.1-aa/`)
- [x] `AccessibilityAuditTests` on tab screens + new tournament
- [x] Nightly UI workflow includes accessibility suite
- [x] `WCAGContrastTests` for semantic color tokens

## Phase 1 — Core flow coverage

- [ ] UI test: accessibility audit on tournament detail (seeded tournament)
- [ ] UI test: attendance + edit-last-round sheets
- [ ] `accessibilityIdentifier` on tournament detail tab picker
- [ ] `accessibilityIdentifier` on Stats segmented control

## Phase 2 — Charts & data visualization

- [ ] `BarChartView` / `LineChartView` / `PieChartView` — `accessibilityLabel` + `accessibilityValue` with data summary
- [ ] Stats VoiceOver spot-check documented in `evidence/voiceover/`

## Phase 3 — Manual sign-off (TestFlight gate)

- [ ] Complete `Manual_todo.md` VoiceOver section
- [ ] AXXXL evidence on 4 core screens
- [ ] Update `SUMMARY.md` Overall status

## Phase 4 — Post-launch

- [ ] Localization + accessibility (when l10n ships)
- [ ] Voice Control testing
- [ ] Bold Text / Increase Contrast matrix
