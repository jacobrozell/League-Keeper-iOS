# League Keeper — Roadmap

**Last updated:** 2026-06-16

---

## Current state

League Keeper is **feature-complete for 1.0** with production infrastructure in progress.

| Area | Status |
|------|--------|
| Core app (17 views, 15 ViewModels, 3 engines) | ✅ Complete |
| Unit / integration tests | ✅ All Models, Engines, ViewModels |
| UI tests | ✅ Flows + accessibility audits |
| Snapshot tests | ✅ Recorded (CI skips until stabilized) |
| CI/CD | ✅ GitHub Actions |
| Documentation | ✅ `docs/` + `specs/` |
| WCAG tracker | ✅ In progress (manual sign-off pending) |
| Firebase | ⚠️ Scaffold only (needs production plist) |
| GitHub Pages | ⚠️ HTML ready (enable in settings) |
| TestFlight | 🔜 Next |
| App Store | 🔜 After TestFlight |

See [feature-inventory.md](feature-inventory.md) for detail.

---

## Phase 1: TestFlight beta ✅ → 🔄

**Goal:** Internal and external beta via TestFlight.

| Task | Status |
|------|--------|
| Xcode Cloud or manual archive pipeline | [testflight.md](release/testflight.md) |
| App icon + screenshots | Open |
| Internal beta group | Open |
| Beta feedback → issues | Open |

**Deliverable:** Build on TestFlight; 2+ full tournaments played by testers.

---

## Phase 2: Accessibility sign-off 🔄

**Goal:** WCAG tracker moves from Partial → Pass for core flow.

| Task | Status |
|------|--------|
| Manual VoiceOver ([Manual_todo.md](../accessibility/Manual_todo.md)) | Open |
| Chart a11y summaries | Open |
| Tournament detail UI audit | Open |
| AXXXL verification | Open |

**Deliverable:** [1.0-ship-checklist.md](release/1.0-ship-checklist.md) accessibility section complete.

---

## Phase 3: App Store 1.0 🔜

**Goal:** Public release.

| Task | Status |
|------|--------|
| GitHub Pages live | Open |
| App Store Connect listing | Copy ready ([app-store-listing.md](app-store-listing.md)) |
| Privacy nutrition labels | Open |
| Submit for review | Open |

**Deliverable:** League Keeper 1.0 on the App Store.

---

## Phase 4: Post-launch

| Feature | Priority |
|---------|----------|
| Crash/analytics monitoring | High |
| User feedback triage | High |
| iCloud backup/sync | Medium |
| Data export (JSON) | Medium |
| Localization | Medium |
| iPad layout polish | Low |
| Widgets / Shortcuts | Low |

---

## Historical note

Earlier versions of this roadmap listed "no tests" and "never compiled" — that reflected pre-implementation planning. The app has since been built with comprehensive test coverage. See [ios-app-plan.md](ios-app-plan.md) for the original implementation plan.

---

## Related

- [release/todo.md](release/todo.md) — actionable release tasks
- [infrastructure.md](infrastructure.md) — CI and tooling status
