# Specification governance

How specs stay accurate as League Keeper evolves.

---

## 1. Ownership

| Area | Primary spec |
|------|--------------|
| Architecture | `ArchitectureSpec.md` |
| Data | `DataSchemaSpec.md` |
| Scoring | `ScoringSpec.md` |
| Navigation | `NavigationSpec.md` |
| Accessibility | `AccessibilitySpec.md` + `accessibility/wcag-2.1-aa/` |
| Tests | `TestPlanSpec.md` |
| Telemetry | `LoggingAnalyticsSpec.md` |
| App Store | `AppStoreConnectSpec.md` |

---

## 2. When to update specs

| Trigger | Action |
|---------|--------|
| Scoring / league rule change | `ScoringSpec.md`, `AppConstants`, tests |
| New screen or flow | `NavigationSpec.md`, WCAG screen file, user-flows |
| New Firebase event | `LoggingAnalyticsSpec.md`, mapping tests |
| Schema change | `DataSchemaSpec.md`, migration tests |
| Ship feature | `docs/feature-inventory.md` |

---

## 3. PR checklist

- [ ] Behavior matches relevant spec(s)
- [ ] Tests added/updated per `TestPlanSpec.md`
- [ ] `docs/feature-inventory.md` updated if user-visible
- [ ] WCAG screen file updated if UI/a11y changed
- [ ] No player-identifying data in new log events

---

## 4. Docs vs specs

| Type | Location | Tone |
|------|----------|------|
| **Spec** | `specs/` | Normative (must/shall) |
| **Guide** | `docs/` | Explanatory (how-to) |
| **Tracker** | `accessibility/wcag-2.1-aa/` | Status + evidence |

If spec and code disagree, fix code or spec in the same PR — never leave drift.

---

## 5. Index

Full catalog: [specs/README.md](README.md)  
Documentation hub: [docs/README.md](../docs/README.md)
