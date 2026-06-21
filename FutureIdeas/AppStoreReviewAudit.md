# App Store Review Audit

Simulator walkthrough (2026-06-20) from the perspective of an **App Store reviewer**, run on iPhone 17 (iOS 18) via fresh installs. Goal: catch anything that would trigger rejection or a metadata query before the first TestFlight/App Review submission.

**Status:** P0/P1 items below were **fixed and re-verified in this pass** (clean build + screenshots). Remaining items are follow-ups — not blockers.

---

## Fixed in this pass

| # | Severity | Issue | Fix | Guideline |
|---|----------|-------|-----|-----------|
| F1 | **P0 — crash on launch** | `NSInvalidArgumentException: 'Duplicate version checksums detected.'` whenever a SwiftData store existed. `LeagueKeeperSchemaV2.models` returned the identical model set as V1, so both versioned schemas produced the same checksum and the migration plan was rejected. | Collapsed to a single clean schema (app never shipped, so no real migration to preserve) — `BudgetLeagueTracker/Persistence/LeagueKeeperMigration.swift` + container now targets `LeagueKeeperSchemaV1`. Verified fresh launch + full weekly loop (attendance → seating → scoring → standings). | 2.1 Performance |
| F2 | **P1 — misleading privacy claim** | Onboarding stated "Nothing is uploaded or synced to a server," but Release builds ship a real Firebase config (`Resources/GoogleService-Info.plist`) with Analytics + Crashlytics enabled by default. Contradicts the (accurate) privacy policy. | Reworded onboarding page 2 to "…stay on this device — no account and no cloud sync. See the Privacy Policy in Settings for details." — `BudgetLeagueTracker/Views/Onboarding/OnboardingView.swift`. | 5.1.1 Data Collection |

---

## Verified OK (no action)

- Core loop (attendance, seating, scoring, finish round, standings) — no crashes; scoring math correct.
- All five tabs (Tournaments, Players, Stats incl. Charts, Achievements, Settings) render and navigate.
- Settings links resolve: Privacy Policy + Support (`AppInfo.swift`) both return 200; privacy policy text accurately discloses Firebase Analytics/Crashlytics in Release.
- Onboarding (4 pages), sample-league load, and empty states all functional.

---

## Follow-ups (not blockers)

| # | Area | Note |
|---|------|------|
| A1 | App Store Connect | Ensure the **privacy nutrition label** declares Analytics + Crash data (Firebase) to match actual Release behavior and the privacy policy. Code/manifest is fine; this is a Connect-side declaration. |
| A2 | Privacy policy copy | External privacy policy still references "Magic: The Gathering budget leagues" while the app ships as generic **League Keeper**. Align wording with the generic positioning (no functional impact). |
| A3 | Buy Me a Coffee link | `buymeacoffee.com/jacobrozelq` — confirm the handle is intentional (vs `jacobrozell`). Donation links to an external site are generally accepted, but verify it loads the right page. |

---

*Method: built/ran via XcodeBuildMCP + iOS-simulator MCP; navigated with synthetic taps and screenshots. See chat history for the full screenshot trail.*
