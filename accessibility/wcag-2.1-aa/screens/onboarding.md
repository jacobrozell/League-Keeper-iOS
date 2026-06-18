# Onboarding

| Field | Value |
|-------|-------|
| Screen ID | `onboarding` |
| Primary source | `Views/Onboarding/OnboardingView.swift` |
| Core flow | Yes (first launch) |
| Last verified | 2026-06-18 |
| Screen status | `Partial` |

## Criterion checklist

| ID | Status | Implementation notes | Evidence |
|----|--------|----------------------|----------|
| P-1.1.1 | Partial | Illustrations decorative; copy is text | [audit C-04](../../audits/2026-06-18-ux-accessibility-audit.md) |
| P-1.3.1 | Pass | Page indicators; structured pages | |
| P-1.3.2 | Partial | Page 4: three CTAs compete for attention | audit C-04 |
| P-1.3.4 | Pass | iPad portrait verified | `evidence/layout/screenshots/2026-06-17/` |
| P-1.4.1 | Pass | State not color-only | |
| P-1.4.3 | Partial | Parchment + gold not verified at Increase Contrast | |
| P-1.4.4 | Partial | `largeText` layout branch; manual AXXXL open | |
| O-2.4.3 | Untested | VoiceOver page order | |
| O-2.4.4 | Partial | “Load sample league” clear; jargon on earlier pages | audit C-04 |
| O-2.5.3 | Pass | Button labels match visible title | |
| LKX-TARGET-44 | Pass | Full-width CTAs ≥ 44pt | |
| U-3.3.2 | Partial | Plain-language copy; page 4 CTA hierarchy improved | audit C-04 partial |
| R-4.1.2 | Partial | Page indicators; buttons labeled | |
| LKX-CONTRAST-MODES | Partial | | |

## Open work

- [x] Rewrite copy for new MTG hosts (plain language, define week/round/table) (2026-06-18)
- [x] Page 4: primary CTA + demoted secondary actions (2026-06-18)
- [ ] VoiceOver pass on all four pages
- [ ] AXXXL screenshot evidence
- [ ] Increase Contrast spot-check on hero + gold accents

## Verification log

| Date | Tester | Result | Notes |
|------|--------|--------|-------|
| 2026-06-18 | Agent | Partial | UX audit — jargon + CTA competition on page 4 |
