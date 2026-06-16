# App Store Connect specification

## 1. App identity

| Field | Value |
|-------|-------|
| App name | League Keeper |
| Subtitle | Budget MTG league tracker |
| Bundle ID | `com.budgetleague.BudgetLeagueTracker` |
| Category | Games |
| SKU | (set in ASC) |

Copy source: [docs/app-store-listing.md](../docs/app-store-listing.md)

---

## 2. Required URLs

| Field | URL |
|-------|-----|
| Privacy Policy | `https://jacobrozell.github.io/League-Keeper-iOS/privacy.html` |
| Support | `https://jacobrozell.github.io/League-Keeper-iOS/support.html` |
| Marketing (optional) | `https://jacobrozell.github.io/League-Keeper-iOS/` |

Enable GitHub Pages: [docs/github-pages.md](../docs/github-pages.md)

---

## 3. Privacy nutrition labels

Declare for **Release** builds:

- **Analytics** — Firebase Analytics (anonymous, allowlisted events)
- **Crash data** — Firebase Crashlytics
- **Data not collected** — contact info, location, user content (league data stays on device)

---

## 4. Screenshots

Required sizes per ASC (6.7", 6.5", **iPad Pro 12.9"/13"**). Capture from simulator:

- Tournaments list with active tournament
- Tournament detail / pod scoring
- Stats charts
- Achievements

**iPad:** Follow layout QA in [iPadLayoutSpec.md](iPadLayoutSpec.md) §8 before capturing; store under `marketing-screenshots/ipad/`.

Store iPhone shots in `marketing-screenshots/` (create when preparing submission).

---

## 5. Versioning

| Field | Source |
|-------|--------|
| Marketing version | `MARKETING_VERSION` in `project.yml` |
| Build number | `CURRENT_PROJECT_VERSION` — increment per upload |

---

## 6. Export compliance

- Uses encryption: standard HTTPS only → typically exempt
- Set `ITSAppUsesNonExemptEncryption` in Info.plist when archiving

---

## 7. Checklist reference

[docs/release/1.0-ship-checklist.md](../docs/release/1.0-ship-checklist.md)
