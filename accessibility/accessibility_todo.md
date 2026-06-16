# Accessibility engineering backlog

Phased work to move `wcag-2.1-aa/SUMMARY.md` from **Not compliant** to **Pass** before App Store release.

## Phase 0 — Tracker & automation (done)

- [x] WCAG 2.1 AA tracker (`accessibility/wcag-2.1-aa/`)
- [x] `AccessibilityAuditTests` on tab screens + new tournament
- [x] Nightly UI workflow includes accessibility suite
- [x] `WCAGContrastTests` for semantic color tokens

## Phase 1 — Core flow coverage

- [x] UI test: accessibility audit on tournament detail (seeded tournament)
- [x] UI test: attendance + edit-last-round sheets
- [x] `accessibilityIdentifier` on tournament detail tab picker
- [x] `accessibilityIdentifier` on Stats segmented control

## Phase 2 — Charts & data visualization

- [x] `BarChartView` / `LineChartView` / `PieChartView` — `accessibilityLabel` + `accessibilityValue` with data summary
- [ ] Stats VoiceOver spot-check documented in `evidence/voiceover/`

## Phase 3 — Manual sign-off (TestFlight gate)

- [ ] Complete `Manual_todo.md` VoiceOver section
- [ ] AXXXL evidence on 4 core screens — layout code: [accessibility-layout-plan.md](../docs/accessibility-layout-plan.md) Phase B
- [ ] Update `SUMMARY.md` Overall status
- [ ] iPad + landscape evidence per [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) §9–11

## Phase 3b — iPad & landscape layout

Spec: [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) · Tasks: [ipad-layout-plan.md](../docs/ipad-layout-plan.md)

- [ ] P-1.4.10 reflow — tournament detail portrait + landscape
- [ ] P-1.4.10 reflow — stats portrait + landscape
- [ ] iPad portrait — onboarding + tournament detail (fill in [layout evidence](../evidence/layout/ipad-landscape-2026-06-16.md))
- [ ] VoiceOver on iPad — core flow spot-check

## Phase 4 — Post-launch

- [ ] Localization + accessibility (when l10n ships)
- [ ] Voice Control testing
- [ ] Bold Text / Increase Contrast matrix
