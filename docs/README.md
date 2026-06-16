# League Keeper documentation

Central index for all project documentation. Start here when onboarding, preparing a release, or changing product behavior.

**Repo:** [github.com/jacobrozell/League-Keeper-iOS](https://github.com/jacobrozell/League-Keeper-iOS)

---

## Quick start

| I want to… | Read |
|------------|------|
| Build and run the app | [development.md](development.md) |
| Understand architecture | [architecture.md](architecture.md) → [specs/ArchitectureSpec.md](../specs/ArchitectureSpec.md) |
| Plan iPad / landscape polish | [ipad-layout-plan.md](ipad-layout-plan.md) → [specs/iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) |
| Learn domain terms | [domain-glossary.md](domain-glossary.md) |
| See what ships vs planned | [feature-inventory.md](feature-inventory.md) |
| Plan 1.0 polish (post–tournament UX) | [polish-plan.md](polish-plan.md) |
| Plan achievement v2 (icons, templates) | [achievement-improvements-plan.md](achievement-improvements-plan.md) |
| Run tests / CI | [testing.md](testing.md) → [infrastructure.md](infrastructure.md) |
| Ship to TestFlight / App Store | [release/README.md](release/README.md) |
| See build-phase status (0 → ship) | [agent-build-checklist.md](agent-build-checklist.md) |
| Fix accessibility | [../accessibility/wcag-2.1-aa/README.md](../accessibility/wcag-2.1-aa/README.md) · [accessibility-layout-plan.md](accessibility-layout-plan.md) |
| Contribute a PR | [../CONTRIBUTING.md](../CONTRIBUTING.md) |

---

## Product & domain

| Document | Description |
|----------|-------------|
| [user-flows.md](user-flows.md) | Main user journeys (create tournament, run week, view results) |
| [domain-glossary.md](domain-glossary.md) | Terms: pod, round, placement points, achievements, etc. |
| [scoring-rules.md](scoring-rules.md) | Placement points, achievements, pod generation, weekly totals |
| [data-model.md](data-model.md) | SwiftData entities, relationships, persistence rules |
| [navigation.md](navigation.md) | Tabs, screen enum, sheets, and navigation state |
| [feature-inventory.md](feature-inventory.md) | Shipped vs partial vs planned features |
| [tournament-ux-improvements.md](tournament-ux-improvements.md) | Tournament host UX review (sprints 1–3, complete) |
| [polish-plan.md](polish-plan.md) | 1.0 polish backlog and sprints 4–6 implementation plan |
| [achievement-improvements-plan.md](achievement-improvements-plan.md) | Achievement v2: icons, templates, tiers, exclusivity (spec: [AchievementSpec.md](../specs/AchievementSpec.md)) |
| [ipad-layout-plan.md](ipad-layout-plan.md) | iPad & landscape polish checklist (spec: [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md)) |
| [accessibility-layout-plan.md](accessibility-layout-plan.md) | Dynamic Type / AXXXL layout reflow (segmented → menu, progress header, standings) |

---

## Engineering

| Document | Description |
|----------|-------------|
| [architecture.md](architecture.md) | Layers, data flow, project structure (overview) |
| [development.md](development.md) | Prerequisites, build, test, where to change things |
| [design-system.md](design-system.md) | Components, colors, touch targets, typography |
| [testing.md](testing.md) | Unit, integration, snapshot, UI, accessibility tests |
| [test-coverage.md](test-coverage.md) | Source → test mapping and coverage gaps |
| [infrastructure.md](infrastructure.md) | CI/CD, Firebase, SwiftLint, GitHub Pages |
| [agent-build-checklist.md](agent-build-checklist.md) | Phase checklist (0 → ship) with progress log |
| [logging-analytics.md](logging-analytics.md) | AppLog, allowlisted events, Crashlytics |

---

## Specifications (`specs/`)

Authoritative requirements for behavior, data, and quality gates. See [specs/README.md](../specs/README.md) for the full index.

| Spec | Topic |
|------|-------|
| [ArchitectureSpec.md](../specs/ArchitectureSpec.md) | Layers, dependencies, conventions |
| [DataSchemaSpec.md](../specs/DataSchemaSpec.md) | SwiftData models and invariants |
| [ScoringSpec.md](../specs/ScoringSpec.md) | League scoring rules (normative) |
| [NavigationSpec.md](../specs/NavigationSpec.md) | Screen state and routing |
| [AccessibilitySpec.md](../specs/AccessibilitySpec.md) | WCAG 2.1 AA requirements |
| [TestPlanSpec.md](../specs/TestPlanSpec.md) | Test strategy and CI gates |
| [LoggingAnalyticsSpec.md](../specs/LoggingAnalyticsSpec.md) | Telemetry allowlist |
| [TechStackSpec.md](../specs/TechStackSpec.md) | Languages, frameworks, tooling |
| [AppStoreConnectSpec.md](../specs/AppStoreConnectSpec.md) | Store metadata and URLs |
| [iPadLayoutSpec.md](../specs/iPadLayoutSpec.md) | iPad + landscape layout requirements |
| [SpecGovernance.md](../specs/SpecGovernance.md) | How specs stay in sync with code |

---

## Release & App Store

| Document | Description |
|----------|-------------|
| [release/README.md](release/README.md) | Release train overview |
| [release/testflight.md](release/testflight.md) | TestFlight setup and beta process |
| [release/1.0-ship-checklist.md](release/1.0-ship-checklist.md) | Pre-submission checklist |
| [release/todo.md](release/todo.md) | Open release tasks |
| [ios-roadmap.md](ios-roadmap.md) | Long-term product roadmap |
| [app-store-listing.md](app-store-listing.md) | Copy-paste App Store Connect text |

---

## Legal, support & accessibility (hosted)

GitHub Pages static site in this folder (`*.html`). Setup: [github-pages.md](github-pages.md).

| Page | Source | Live URL (after Pages enabled) |
|------|--------|--------------------------------|
| Home | [index.html](index.html) | `https://jacobrozell.github.io/League-Keeper-iOS/` |
| Privacy | [privacy.html](privacy.html) / [privacy-policy.md](privacy-policy.md) | `…/privacy.html` |
| Support | [support.html](support.html) / [support.md](support.md) | `…/support.html` |
| Accessibility | [accessibility.html](accessibility.html) | `…/accessibility.html` |

WCAG compliance tracker (not hosted): [accessibility/wcag-2.1-aa/](../accessibility/wcag-2.1-aa/)

---

## Historical / planning

| Document | Description |
|----------|-------------|
| [ios-app-plan.md](ios-app-plan.md) | Original iOS implementation plan |
| [../CHANGELOG.md](../CHANGELOG.md) | Version history |

---

## Documentation conventions

- **Overview docs** (`docs/*.md`) — readable narratives and how-tos.
- **Specs** (`specs/*.md`) — normative requirements; update when behavior changes.
- **Tracker** (`accessibility/wcag-2.1-aa/`) — per-screen WCAG status and evidence.
- When shipping a feature, update the spec, feature inventory, and (if UI) the WCAG screen file in the same PR.
