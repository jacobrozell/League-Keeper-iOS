# Players UI enhancement plan

**Status:** Implemented (pre-1.0)  
**Reference:** Dart Buddy `PlayerStatsDetailView`, `PlayersRootView`  
**Primary surfaces:** `PlayersView`, `PlayerDetailView`, shared components

---

## 1. Goals

Make the Players tab feel like a first-class league hub—not just a roster with aggregate numbers.

| Goal | Success signal |
|------|----------------|
| Scannable list | Rank, form, and avatar visible without opening detail |
| Rich detail | Hero identity, scoped stats, round drill-down, trophies |
| Competitive flavor | Head-to-head compare, league rank, placement form |
| Low friction | Search, sort, rename without delete-and-recreate |

No new SwiftData models required except using existing `GameResult`, `Tournament.attendanceHistory`, and `Achievement` data.

---

## 2. Feature inventory

### Phase A — List polish (Players tab)

| # | Feature | Component / file | Data source |
|---|---------|----------------|-------------|
| A1 | Avatar chips (initials + stable color) | `PlayerAvatarView` | `player.id` hash → palette |
| A2 | League rank badge | `PlayerRow`, `PlayersViewModel` | `Player.totalPoints` sort |
| A3 | Recent form dots (last 8 placements) | `PlayerFormDotsView` | `StatsEngine.recentPlacements` |
| A4 | Mini points sparkline | `PlayerSparklineView` | Last N `GameResult.totalPoints` cumulative |
| A5 | Search by name | `PlayersView` `.searchable` | Client filter |
| A6 | Sort: Name, Points, Wins, Games, Recent | `PlayerSortOption`, view model | `GameResult.timestamp` for Recent |

### Phase B — Detail identity & scope

| # | Feature | Component / file | Data source |
|---|---------|----------------|-------------|
| B1 | Hero identity card | `PlayerIdentityCard` | Avatar + rank + win rate + last played |
| B2 | Tournament scope picker | `PlayerDetailScope`, segmented/menu | All-time vs per-`Tournament` |
| B3 | Scoped stat tiles | `PlayerDetailViewModel` | `StatsEngine.tournamentStats` filter |
| B4 | Attendance ring | `Gauge` in attendance section | `PlayerAttendanceSummary` percentage |

### Phase C — History & social

| # | Feature | Component / file | Data source |
|---|---------|----------------|-------------|
| C1 | Tappable recent rounds | `PlayerRoundRow` + button | Existing summaries |
| C2 | Round detail sheet | `PlayerRoundDetailSheet` | Pod via `podId`, achievements by ID |
| C3 | Head-to-head compare | `PlayerHeadToHeadSection` | `StatsEngine.headToHeadRecord` |
| C4 | Achievement gallery | `PlayerAchievementGallerySection` | `AchievementStatsEngine.playerAchievementHistory` |

### Phase D — Management

| # | Feature | Component / file | Data source |
|---|---------|----------------|-------------|
| D1 | Edit player name | `PlayerEditNameSheet`, toolbar | `LeagueEngine.updatePlayerName` |

### Deferred (post-1.0)

- Player archive / soft-delete
- Export player bundle (Dart Buddy parity)
- Pod photo / custom avatar upload
- Cross-tournament sparkline on iPad wide layout only

---

## 3. Architecture

```
PlayersView
  └── PlayersViewModel
        ├── players[], gameResults[], searchText, sortOption
        ├── filteredPlayers, rank(for:), formDots(for:)
        └── refresh() → StatsEngine helpers

PlayerDetailView
  └── PlayerDetailViewModel
        ├── selectedScope: PlayerDetailScope
        ├── scopedResults, scopedStats, achievementGallery
        ├── headToHeadOpponentId, headToHeadRecord
        ├── selectedRoundDetail → sheet
        └── updateName(), refresh()
```

**Engine additions (`StatsEngine`):**

- `leagueRanks(players:) -> [String: Int]`
- `recentPlacements(playerId:results:limit:) -> [Int]`
- `sparklinePoints(playerId:results:limit:) -> [Double]`
- `roundDetail(...) -> PlayerRoundDetail?`

**Engine additions (`LeagueEngine`):**

- `updatePlayer(context:id:name:nameNote:) -> String?` — trim, reject empty; duplicate display names allowed

**Duplicate display names:**

- Identity is always `player.id`; scoring uses IDs, not names.
- Optional `nameNote` (nickname) on add/edit — shown as `Devan (Smith)`.
- Without a note, auto-number peers: `Devan (1)`, `Devan (2)` (stable by `id`).
- `PlayerDisambiguation.displayName(for:among:)` used everywhere names appear in UI.
- Add-player sheet shows a hint when name matches an existing player and no nickname is set.

---

## 4. UI specifications

### 4.1 Avatar (`PlayerAvatarView`)

- Circle, initials from first letter of first two words (or first two chars)
- Background: one of 8 accessible hues from `player.id` hash
- Sizes: `.small` (36pt list), `.large` (72pt hero)
- VoiceOver: "\(name) avatar"

### 4.2 Form dots (`PlayerFormDotsView`)

- Row of up to 8 circles, 10pt diameter, 4pt spacing
- Colors: 1st = green, 2nd = blue, 3rd = gray, 4th = tertiary
- VoiceOver: "Recent form: 1st, 2nd, 1st, …"

### 4.3 List row layout

```
[Avatar]  Name                    #2
          142 pts • 18 games      [sparkline]
          ● ● ● ● ○ ○ ○ ○
```

### 4.4 Hero card

- Large avatar, name (serif headline), rank pill, win rate, last played
- Sits above scope picker; replaces redundant nav subtitle

### 4.5 Attendance ring

- `Gauge(value:in:)` 0…1 with percent label center
- Per-tournament rows keep text; overall uses ring

### 4.6 Round detail sheet

- Title: tournament + week/round
- Placement + points breakdown
- Pod table: name, place, points (self row highlighted)
- Achievements earned (icon + name)

### 4.7 Head-to-head

- Picker: "Compare with…" (all other players)
- Summary: "Alex leads 7–4 (3 shared pods)"

### 4.8 Achievement gallery

- Horizontal scroll or 2-column grid of earned badges
- Icon, name, ×count; hide section if empty

---

## 5. Accessibility

- All new controls: `accessibilityLabel` / `accessibilityIdentifier` where UI-tested
- Form dots and sparklines: `accessibilityElement(children: .ignore)` with summary label
- Attendance ring: announce percent + weeks fraction
- Update `accessibility/wcag-2.1-aa/screens/player-detail.md` after ship

---

## 6. Testing

| Area | Tests |
|------|-------|
| `StatsEngine` | `leagueRanks`, `recentPlacements`, `roundDetail` |
| `LeagueEngine` | `updatePlayer` validation; duplicate names allowed |
| `PlayerDisambiguation` | numbering, nickname labels |
| `PlayersViewModel` | search, sort, rank |
| `PlayerDetailViewModel` | scope filtering, h2h, achievements |

---

## 7. Implementation checklist

- [x] `docs/players-ui-plan.md` (this file)
- [x] `PlayerAvatarView`, `PlayerFormDotsView`, `PlayerSparklineView`
- [x] `PlayerIdentityCard`, `PlayerAchievementGallerySection`, `PlayerHeadToHeadSection`
- [x] `PlayerRoundDetailSheet`, `PlayerEditNameSheet`
- [x] `StatsEngine` + `LeagueEngine` helpers
- [x] `PlayersViewModel` + `PlayersView`
- [x] `PlayerDetailViewModel` + `PlayerDetailView`
- [x] `PlayerRow` display mode extensions
- [x] Unit tests

### Phase E — UX polish (2026-06-16)

- [x] Stats Players segment → rich rows + navigation to detail
- [x] Duplicate name disambiguation (`nameNote` + auto-numbering via `PlayerDisambiguation`)
- [x] Add-player haptic + toast
- [x] Win streak / form highlight on player detail hero
- [x] Share standings on Stats weekly + all-time sections
- [x] Pull to refresh on player detail
- [x] Persist players list sort preference

---

## 8. Marketing / screenshots

Good App Store frames from this work:

1. Players list with avatars, ranks, and form dots
2. Player detail hero + achievement gallery
3. Round detail sheet showing podmates

See [app-store-listing.md](app-store-listing.md) for copy alignment.
