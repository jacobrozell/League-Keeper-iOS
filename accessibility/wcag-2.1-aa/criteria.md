# WCAG 2.1 AA criteria map (League Keeper)

Success criteria in scope for the iOS app. **Required** = release gate for core flows. **Recommended** = track before GA.

League Keeper extensions (**LKX-***) are app-specific checks beyond WCAG.

---

## Perceivable

| ID | WCAG SC | Level | Required | iOS / app check | Global status | Notes |
|----|---------|-------|----------|-----------------|---------------|-------|
| P-1.1.1 | 1.1.1 Non-text Content | A | Yes | Charts and icons have text alternatives | Partial | Charts need richer VoiceOver summaries |
| P-1.3.1 | 1.3.1 Info and Relationships | A | Yes | Lists, forms, and grouped controls expose structure | Partial | `List` / `Form` patterns; tournament detail tabs |
| P-1.3.2 | 1.3.2 Meaningful Sequence | A | Yes | VoiceOver order matches visual priority | Untested | Manual VO per screen |
| P-1.3.4 | 1.3.4 Orientation | AA | Yes | Portrait and landscape complete core tasks | Partial | UI tests cover landscape on Tournaments |
| P-1.4.1 | 1.4.1 Use of Color | A | Yes | State not conveyed by color alone | Partial | Placement badges use text + color |
| P-1.4.3 | 1.4.3 Contrast (Minimum) | AA | Yes | 4.5:1 normal text, 3:1 large text | Partial | `AppConstants.AccessibleColors` uses semantic UIKit colors |
| P-1.4.4 | 1.4.4 Resize Text | AA | Yes | Dynamic Type through accessibility sizes | Partial | Row caps at AX5; manual AXXXL verify |
| P-1.4.10 | 1.4.10 Reflow | AA | Yes | No horizontal scroll at 320pt width equivalent | Untested | Stats charts + tournament detail |
| P-1.4.11 | 1.4.11 Non-text Contrast | AA | Yes | Control boundaries ≥ 3:1 | Untested | Steppers, segmented controls |
| LKX-CONTRAST-MODES | — | — | Yes | Light and dark both pass P-1.4.3 on primary surfaces | Partial | System semantic colors adapt automatically |

---

## Operable

| ID | WCAG SC | Level | Required | iOS / app check | Global status | Notes |
|----|---------|-------|----------|-----------------|---------------|-------|
| O-2.1.1 | 2.1.1 Keyboard | A | N/A* | External keyboard reaches controls | N/A | Touch-first iPhone app |
| O-2.4.3 | 2.4.3 Focus Order | A | Yes | VoiceOver focus order logical | Untested | |
| O-2.4.4 | 2.4.4 Link Purpose (In Context) | A | Yes | Buttons describe action in label | Partial | Toolbar + empty-state CTAs labeled |
| O-2.5.1 | 2.5.1 Pointer Gestures | A | Yes | No path-only gestures for essential actions | Pass | Tap-only |
| O-2.5.2 | 2.5.2 Pointer Cancellation | A | Yes | Destructive actions confirm | Partial | Delete tournament; verify all destructive flows |
| O-2.5.3 | 2.5.3 Label in Name | A | Yes | Visible label matches accessible name | Partial | Custom buttons use visible title as label |
| O-2.5.4 | 2.5.4 Motion Actuation | A | Yes | No shake/tilt-only actions | Pass | |
| LKX-TARGET-44 | — | — | Yes | Interactive targets ≥ 44×44 pt | Partial | `PrimaryActionButton` enforces 44pt; verify steppers |
| LKX-REDUCE-MOTION | — | — | Recommended | Respect Reduce Motion for non-essential animation | Untested | |

---

## Understandable

| ID | WCAG SC | Level | Required | iOS / app check | Global status | Notes |
|----|---------|-------|----------|-----------------|---------------|-------|
| U-3.1.1 | 3.1.1 Language of Page | A | Yes | App language is English | Pass | English only in v1.0 |
| U-3.2.1 | 3.2.1 On Focus | A | Yes | Focus does not auto-change context | Pass | |
| U-3.2.2 | 3.2.2 On Input | A | Yes | Input does not auto-submit unexpectedly | Pass | |
| U-3.3.1 | 3.3.1 Error Identification | A | Yes | Errors described in text | Partial | Form validation messages |
| U-3.3.2 | 3.3.2 Labels or Instructions | A | Yes | Inputs have visible + accessible labels | Partial | `LabeledStepper`, `LabeledToggle`, form fields |

---

## Robust

| ID | WCAG SC | Level | Required | iOS / app check | Global status | Notes |
|----|---------|-------|----------|-----------------|---------------|-------|
| R-4.1.2 | 4.1.2 Name, Role, Value | A | Yes | Controls expose name, role, state, value | Partial | Toggles/steppers in forms; chart gaps |
| LKX-A11Y-IDS | — | — | Recommended | Stable `accessibilityIdentifier` for automation | Partial | Components + key flows; not universal |
| LKX-CHART-A11Y | — | — | Yes | Charts summarize data for VoiceOver | Partial | `BarChartView`, `LineChartView`, `PieChartView` |

---

## Core flow definition

Release-critical path:

`tournaments` → `new-tournament` → `add-players` → `tournament-detail` → (`attendance`) → weekly rounds → `tournament-standings`

Plus tab sustainability: `players`, `stats`, `achievements`, `settings`.

---

## Verification methods

| Method | Tool / action | Evidence location |
|--------|---------------|---------------------|
| VoiceOver | Device or Simulator + VO on | `evidence/voiceover/` |
| Automated XCTest | `AccessibilityAuditTests` | CI nightly |
| Dynamic Type | Settings → Larger Text → AXXXL | `evidence/dynamic-type/` |
| Contrast | Accessibility Inspector + unit tests | `evidence/contrast/` |
| Orientation | Portrait + landscape × light + dark | `evidence/orientation/` |
