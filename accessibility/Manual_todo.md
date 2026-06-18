# Manual accessibility verification

Human-only checks that automated tools cannot complete. Tick items when done and link evidence under `accessibility/wcag-2.1-aa/evidence/`.

**WCAG rollup:** [`wcag-2.1-aa/SUMMARY.md`](wcag-2.1-aa/SUMMARY.md)

---

## VoiceOver — Core tournament flow

- [ ] **Tournaments** — Create tournament from empty state; hear CTA label
- [ ] **New tournament** — Name field, week stepper, player toggles; submit enabled state
- [ ] **Add players** — Add/remove players; continue to tournament
- [x] **Tournament detail** — Switch Attendance / Pods / Standings tabs; hear selected tab *(2026-06-17 sim: section picker announces “Selected, Pods”; Standings switch needs XCTest/device finger tap)*
- [x] **Attendance sheet** — Toggle players present/absent; confirm *(2026-06-17 sim iPad: “Mark Alice as present”, Confirm Attendance labeled)*
- [x] **Pods** — Record placement for each player in a pod; advance week *(2026-06-17: “Placement for Dave”, achievement toggles with hints; pod header separate)*
- [ ] **Edit last round** — Change placement; save
- [ ] **Tournament standings** — Final rankings read rank → name → points

## VoiceOver — Tabs

- [ ] **Players** — List navigation; open player detail
- [ ] **Player detail** — Stats and tournament history
- [ ] **Stats** — Segmented control (Weekly / Standings / Charts / Players); each segment content
- [ ] **Achievements** — List; add achievement sheet
- [ ] **Settings** — About section (version, build, credit) *(labels added 2026-06-17; device VO pass pending)*

## Dynamic Type (AXXXL)

- [ ] New tournament form — all fields and submit reachable
- [ ] Tournament detail — tabs and pod list scroll without clipping
- [ ] Stats — charts and tables readable or gracefully scroll
- [ ] Achievements — rows do not overlap
- [ ] Onboarding — page 4 CTAs at AXXXL

**Code fixes 2026-06-18:** list rows scale to AXXXL; `StatTile` reflow; segmented → menu pickers.

## Contrast & appearance

- [ ] Light mode — primary text on grouped backgrounds (see `evidence/contrast/`)
- [ ] Dark mode — same checks on Tournaments + Stats
- [ ] Increase Contrast (iOS setting) — verify primary CTAs still readable

## Orientation

- [x] Portrait — complete core flow *(2026-06-17 sim: iPhone pods + iPad onboarding/attendance)*
- [x] Landscape — tournaments list + tournament detail usable *(2026-06-17 sim: iPad landscape attendance centered, confirm visible; iPhone pods bar horizontal)*

## Reduce Motion

- [ ] Tournament standings presentation — no essential info motion-only
- [ ] Sheet transitions — content readable with Reduce Motion on

---

When an item passes, add a row to the screen's **Verification log** in `wcag-2.1-aa/screens/` and update counts in `SUMMARY.md`.
