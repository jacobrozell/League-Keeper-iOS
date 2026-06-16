# Marketing & accessibility screenshots — future work

**Status:** Planned (not implemented)  
**Last updated:** 2026-06-16  
**Reference implementation:** [Dart-Buddy/Scripts](https://github.com/jacobrozell/Dart-Buddy/tree/main/Scripts) (`capture-marketing-screenshots.sh`, `capture-accessibility-screenshots.sh`, etc.)

Automate App Store marketing screenshots and WCAG Dynamic Type evidence using **simulator shell capture** (`simctl launch` + `simctl io screenshot`), not UI test attachments.

---

## Goals

1. **App Store Connect** — iPhone and iPad PNGs at required dimensions ([AppStoreConnectSpec.md](../../specs/AppStoreConnectSpec.md) §4).
2. **WCAG evidence** — AXXXL captures for manual sign-off ([Manual_todo.md](../../accessibility/Manual_todo.md) § Dynamic Type).
3. **Repeatability** — One command regenerates the full matrix after UI changes.

---

## Capture matrix

| Device | Mode | Portrait | Landscape | Output folder |
|--------|------|----------|-----------|---------------|
| iPhone | Light marketing | ✓ | ✓ | `marketing-screenshots/raw/` |
| iPhone | Dark marketing | ✓ | ✓ | `marketing-screenshots/raw/` |
| iPhone | Light AXXXL | ✓ | ✓ | `accessibility/screenshots/` + `…/landscape/` |
| iPhone | Dark AXXXL | ✓ | ✓ | same |
| iPad 13" | Light marketing | ✓ | ✓ | `marketing-screenshots/ipad/raw/` |
| iPad 13" | Dark marketing | ✓ | ✓ | same |
| iPad 13" | Light AXXXL | ✓ | ✓ | `accessibility/screenshots/ipad/` + `…/ipad/landscape/` |
| iPad 13" | Dark AXXXL | ✓ | ✓ | same |

**Orchestrator (planned):** `./Scripts/capture-all-screenshots.sh` — loops `light` and `dark` over the four capture scripts below.

---

## Scripts to add

Port from Dart Buddy; adapt bundle ID, scheme, and launch arguments for League Keeper.

| Script | Purpose |
|--------|---------|
| `Scripts/simulator-orientation.sh` | Normalize and verify portrait/landscape PNG dimensions |
| `Scripts/app-store-screenshot-size.sh` | Resize to ASC slots (iPhone 1284×2778; iPad 2064×2752) |
| `Scripts/capture-marketing-screenshots.sh` | iPhone marketing — portrait + landscape per run |
| `Scripts/capture-ipad-marketing-screenshots.sh` | Thin wrapper → iPad sim + `ipad/raw/` |
| `Scripts/capture-accessibility-screenshots.sh` | iPhone AXXXL portrait (`simctl ui content_size`) |
| `Scripts/capture-accessibility-screenshots-landscape.sh` | AXXXL landscape; routes iPad output to `ipad/landscape/` |
| `Scripts/capture-all-screenshots.sh` | Full light/dark matrix |

**Optional (post-1.0):** `Scripts/frame-marketing-screenshots.sh` — device bezels for website/press (not App Store upload).

**Dependencies:** ImageMagick (`brew install imagemagick`), `xcodegen`, Xcode simulators.

**Defaults:**

| Setting | Value |
|---------|-------|
| iPhone simulator | `iPhone 17 Pro` |
| iPad simulator | Newest available `iPad Pro 13-inch` |
| Marketing appearance default | `dark` (matrix script runs both) |
| `LAUNCH_DELAY` | 5s marketing, 4s accessibility |
| Resize | `APP_STORE_RESIZE=1` unless capturing native Pro Max pixels |

---

## Screens to capture

App Store priority ([app-store-listing.md](../app-store-listing.md), [AppStoreConnectSpec.md](../../specs/AppStoreConnectSpec.md) §4):

| # | Screen | Planned launch arguments |
|---|--------|--------------------------|
| 01 | Tournaments (active league) | `-ui_test_reset -seed_demo` |
| 02 | Tournament detail — Pods | `-seed_demo -snapshot_tournament_detail pods` |
| 03 | Tournament detail — Standings | `-seed_demo -snapshot_tournament_detail standings` |
| 04 | Stats (charts) | `-seed_demo -snapshot_tab stats` |
| 05 | Achievements | `-seed_demo -snapshot_tab achievements` |
| 06 | Onboarding | `-ui_test_reset -ui_test_onboarding` |
| 07 | Settings | `-seed_demo -snapshot_tab settings` |

**Accessibility subset** (WCAG evidence — can be leaner than marketing):

- Tournaments, tournament detail (pods), stats, settings, onboarding

**Filename conventions** (Dart Buddy style):

- Marketing: `{device-slug}-02-pods-dark-landscape.png`
- AXXXL: `{device}-tournament-pods_dark_accessibility-extra-extra-extra-large-landscape.png`

---

## App-side work (required before scripts run)

League Keeper has `UITestBootstrap` and theme launch args but not snapshot routing. Implement before first capture:

| Item | Notes |
|------|-------|
| `Support/Snapshot/SnapshotOrientationLock.swift` | Lock orientation via `-snapshot_orientation portrait\|landscape`; wire in `AppDelegate.supportedInterfaceOrientationsFor` |
| Marketing seed bootstrap | `-seed_demo`: rich league (8 players, week 2, scored pods, optional completed tournament). Reuse `DemoLeagueLoader` / `LeagueEngine` patterns |
| `-ui_test_reset` | In-memory SwiftData store + wipe; skip onboarding |
| `-snapshot_tab` | `tournaments` / `players` / `stats` / `achievements` / `settings` — requires `TabView` selection binding in `ContentView` |
| `-snapshot_tournament_detail` | `pods` / `standings` / `attendance` + auto-navigate to tournament |
| `-ui_test_onboarding` | Force onboarding fullscreen |
| Splash skip | Extend `AppShell` to skip splash for snapshot launch args (not only `--uitesting`) |
| Theme determinism | `simctl ui appearance` + `UI-Testing-LightTheme` / `UI-Testing-DarkTheme` so `@AppStorage` theme does not fight the simulator |
| AXXXL via shell | `simctl ui content_size accessibility-extra-extra-extra-large` for accessibility scripts |

**Existing code to extend:** `UITestBootstrap.swift`, `DemoLeagueLoader.swift`, `ThemePreference.swift`, `AppShell.swift`, `OnboardingStore.swift`, `LeagueKeeperModelContainer.swift`.

---

## Output folder layout

```
marketing-screenshots/
  README.md
  raw/                      # iPhone → App Store upload (no bezels)
  ipad/raw/                 # iPad 12.9"/13" → App Store upload

accessibility/screenshots/
  README.md
  *.png                     # iPhone AXXXL portrait
  landscape/*.png           # iPhone AXXXL landscape
  ipad/*.png                # iPad AXXXL portrait
  ipad/landscape/*.png      # iPad AXXXL landscape
```

Link AXXXL captures from [accessibility/wcag-2.1-aa/evidence/dynamic-type/](../../accessibility/wcag-2.1-aa/evidence/dynamic-type/) when populated.

---

## Release timeline (when implemented)

Fits week 2 of the 1.0 release train ([1.0-ship-checklist.md](1.0-ship-checklist.md)):

| Step | Work |
|------|------|
| 1 | App snapshot routing + orientation lock |
| 2 | Port shell scripts from Dart Buddy |
| 3 | `./Scripts/capture-all-screenshots.sh` |
| 4 | Upload `marketing-screenshots/raw/` and `ipad/raw/` to App Store Connect |
| 5 | Reference AXXXL shots in WCAG tracker + `Manual_todo.md` |

Re-run the matrix only when marketing-relevant UI changes during beta.

---

## Differences from Dart Buddy

| Dart Buddy | League Keeper |
|------------|---------------|
| `-snapshot_match_x01` | `-snapshot_tournament_detail pods` |
| `-snapshot_tab activity` | `-snapshot_tab stats` |
| Tabs: play, modes, players, … | Tabs: tournaments, players, stats, achievements, settings |
| Async `DemoSeeder` | Sync `DemoLeagueLoader` + `LeagueEngine` |
| No splash | `AppShell` branded splash — skip for snapshot launches |

---

## Related

- [1.0-ship-checklist.md](1.0-ship-checklist.md) — App assets + accessibility gates
- [todo.md](todo.md) — open release tasks
- [polish-plan.md](../polish-plan.md) — Sprint 6 (QA + TestFlight)
- [ipad-layout-plan.md](../ipad-layout-plan.md) — layout QA before iPad captures
- [accessibility-layout-plan.md](../accessibility-layout-plan.md) — AXXXL layout reflow
