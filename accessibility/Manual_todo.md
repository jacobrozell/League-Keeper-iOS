# Manual accessibility verification

Human-only checks that automated tools cannot complete. Tick items when done and link evidence under `accessibility/wcag-2.1-aa/evidence/`.

**WCAG rollup:** [`wcag-2.1-aa/SUMMARY.md`](wcag-2.1-aa/SUMMARY.md)

---

## VoiceOver — Core tournament flow

- [ ] **Tournaments** — Create tournament from empty state; hear CTA label
- [ ] **New tournament** — Name field, week stepper, player toggles; submit enabled state
- [ ] **Add players** — Add/remove players; continue to tournament
- [ ] **Tournament detail** — Switch Attendance / Pods / Standings tabs; hear selected tab
- [ ] **Attendance sheet** — Toggle players present/absent; confirm
- [ ] **Pods** — Record placement for each player in a pod; advance week
- [ ] **Edit last round** — Change placement; save
- [ ] **Tournament standings** — Final rankings read rank → name → points

## VoiceOver — Tabs

- [ ] **Players** — List navigation; open player detail
- [ ] **Player detail** — Stats and tournament history
- [ ] **Stats** — Segmented control (Weekly / Standings / Charts / Players); each segment content
- [ ] **Achievements** — List; add achievement sheet
- [ ] **Settings** — About section (version, build, credit)

## Dynamic Type (AXXXL)

- [ ] New tournament form — all fields and submit reachable
- [ ] Tournament detail — tabs and pod list scroll without clipping
- [ ] Stats — charts and tables readable or gracefully scroll
- [ ] Achievements — rows do not overlap

## Contrast & appearance

- [ ] Light mode — primary text on grouped backgrounds (see `evidence/contrast/`)
- [ ] Dark mode — same checks on Tournaments + Stats
- [ ] Increase Contrast (iOS setting) — verify primary CTAs still readable

## Orientation

- [ ] Portrait — complete core flow
- [ ] Landscape — tournaments list + tournament detail usable

## Reduce Motion

- [ ] Tournament standings presentation — no essential info motion-only
- [ ] Sheet transitions — content readable with Reduce Motion on

---

When an item passes, add a row to the screen's **Verification log** in `wcag-2.1-aa/screens/` and update counts in `SUMMARY.md`.
