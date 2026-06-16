# Semantic color contrast audit

**Date:** 2026-06-16  
**Method:** `WCAGContrastTests` unit tests + iOS semantic color documentation

League Keeper uses UIKit semantic colors via `AppConstants.AccessibleColors`:

| Token | UIKit source | Notes |
|-------|--------------|-------|
| `secondaryText` | `.secondaryLabel` | Apple guarantees adapted contrast on backgrounds |
| `activeStatus` | `.systemGreen` | Status badges |
| `winnerAccent` | `.systemYellow` | Large text / decorative |
| `placementAccent` | `.systemBlue` | Legend |
| `achievementAccent` | `.systemGreen` | Legend |

## Automated checks

See `BudgetLeagueTrackerTests/Accessibility/WCAGContrastTests.swift`:

- Primary label on grouped background (light + dark approximations) ≥ 4.5:1
- Secondary label composite ≥ 4.5:1
- White on system blue (button prominent style approximation) ≥ 4.5:1

## Manual follow-up

- [ ] Accessibility Inspector on Stats chart legend colors
- [ ] Winner yellow on completed tournament row in dark mode
