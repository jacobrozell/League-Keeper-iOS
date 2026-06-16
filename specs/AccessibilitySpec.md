# Accessibility specification

## 1. Purpose

Define accessibility requirements for League Keeper. WCAG 2.1 Level AA is the target standard.

---

## 2. Scope

- iPhone and iPad (universal binary)
- Portrait and landscape for core flows — layout requirements in [iPadLayoutSpec.md](iPadLayoutSpec.md)
- English UI in v1.0
- VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast

---

## 3. Core requirements

- Text contrast meets WCAG 2.1 AA (4.5:1 normal, 3:1 large).
- Interactive controls reachable and understandable with VoiceOver.
- Minimum touch target **44×44 pt** on custom buttons.
- Do not rely on color alone (badges include text).
- Support Dynamic Type without clipping critical content.
- Light and dark mode both pass contrast on primary surfaces.

---

## 4. Engineering rules

- Custom buttons use `accessibilityLabel` (default: visible title).
- Form controls use `accessibilityIdentifier` for UI tests (`toggle-*`, stepper IDs).
- Charts must expose a summary via accessibility API (see `LKX-CHART-A11Y`).
- Use `AppConstants.AccessibleColors` — not hardcoded RGB.
- No `print()` in production — use `AppLog`.

---

## 5. Testing

| Method | Location |
|--------|----------|
| WCAG tracker | `accessibility/wcag-2.1-aa/` |
| Manual checklist | `accessibility/Manual_todo.md` |
| UI audits | `AccessibilityAuditTests` |
| Contrast unit tests | `WCAGContrastTests` |
| Nightly CI | `.github/workflows/nightly-ui.yml` |

---

## 6. Release gate

Do not ship 1.0 to App Store while:

- Any **core flow** screen has Required criterion `Fail` in WCAG tracker
- Manual VoiceOver checklist incomplete (`Manual_todo.md`)
- Hosted [accessibility.html](../docs/accessibility.html) is stale vs actual behavior

---

## 7. Related

- [accessibility/wcag-2.1-aa/criteria.md](../accessibility/wcag-2.1-aa/criteria.md)
- [docs/design-system.md](../docs/design-system.md)
