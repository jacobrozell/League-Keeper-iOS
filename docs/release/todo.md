# Release todo

Open tasks for League Keeper 1.0. Move items to [1.0-ship-checklist.md](1.0-ship-checklist.md) when done.

**Polish implementation plan:** [polish-plan.md](../polish-plan.md) (sprints 4–6 — share standings, settings links, a11y gate, QA).

---

## TestFlight (next)

- [ ] Configure Xcode Cloud archive workflow
- [ ] First internal TestFlight upload
- [ ] Recruit 2–3 beta testers for full-season playthrough

---

## App Store blockers

- [ ] Enable GitHub Pages on repo
- [x] Add App Icon 1024 PNG to asset catalog (`Scripts/generate-launch-assets.py`)
- [ ] Capture marketing screenshots — see [marketing-screenshots-plan.md](marketing-screenshots-plan.md)
- [ ] Create App Store Connect app record

---

## iPad & landscape (pre–TestFlight)

Spec: [iPadLayoutSpec.md](../../specs/iPadLayoutSpec.md) · Checklist: [ipad-layout-plan.md](../ipad-layout-plan.md)

### Phase A — P0 (internal TestFlight)

- [ ] Fix onboarding copy (“device” not “phone”)
- [ ] Stack pods sticky action bar in landscape (`usesStackedRowLayout`)
- [ ] Manual QA: iPhone landscape tournament detail Pods
- [ ] Manual QA: iPad portrait onboarding → sample league → attendance

### Phase B — P1 (client demo)

- [ ] `adaptiveContentWidth()` modifier (~680 pt) on core screens
- [ ] Onboarding wide layout on iPad portrait
- [ ] iPad + landscape snapshot tests
- [ ] iPad Pro ASC screenshots

### Phase C — P2 (1.0 polish)

- [ ] Optional: deep-link sample league into tournament after onboarding
- [ ] WCAG P-1.4.10 landscape evidence on tournament detail + stats

---

## Accessibility (pre-submit)

- [ ] Complete VoiceOver section in [Manual_todo.md](../../accessibility/Manual_todo.md)
- [ ] Chart VoiceOver summaries (Phase 2 in [accessibility_todo.md](../../accessibility/accessibility_todo.md))
- [ ] UI audit for tournament detail with seeded data
- [ ] iPad + landscape manual pass per [iPadLayoutSpec.md](../../specs/iPadLayoutSpec.md) §11

---

## Infrastructure

- [ ] Add production Firebase project + plist (local only)
- [ ] Commit snapshot references for CI snapshot suite
- [ ] Optional: Slack CI notifications

---

## Post-1.0 backlog

See [feature-inventory.md](../feature-inventory.md) and [ios-roadmap.md](../ios-roadmap.md).
