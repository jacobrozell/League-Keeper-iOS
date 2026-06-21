# Reviewer-Readiness Handoff — League Keeper

Handoff for a new agent continuing the **App Store reviewer-readiness** effort. Pairs with [AppStoreReviewAudit.md](AppStoreReviewAudit.md). Goal: reach a state where we're confident an App Store reviewer would pass, then do the first TestFlight upload.

> Last updated: 2026-06-21 · Stage: Pre–TestFlight (1.0.0 build 1)

---

## Completed (2026-06-21)

- **P0 launch crash** — SwiftData duplicate schema checksums; collapsed to `LeagueKeeperSchemaV1` only.
- **P1 privacy copy** — onboarding page 2 references no-account/no-cloud-sync + Privacy Policy.
- **Privacy policy alignment** — `docs/privacy.html` + `docs/privacy-policy.md` use generic League Keeper wording; data-collection section matches Firebase disclosure.
- **Migration tests** — `LeagueKeeperMigrationTests` green (2/2); test renamed for clarity.
- **Buy Me a Coffee** — `buymeacoffee.com/jacobrozelq` verified (Jacob Rozell iOS Apps page; intentional vs personal `jacobrozell` handle).
- **Fresh-install QA** — iPhone 17 sim: launches, onboarding pages 1–2 verified, no crash.
- **Committed** — see `main` commit on 2026-06-21.

---

## Remaining (human / Connect-side)

1. **App Store Connect — privacy nutrition label** — see checklist in [`../docs/release/1.0-ship-checklist.md`](../docs/release/1.0-ship-checklist.md) § Legal & URLs.
2. **Publish updated privacy.html** — enable GitHub Pages or push docs so hosted URL matches repo copy.
3. **First TestFlight upload** — [`../docs/release/testflight.md`](../docs/release/testflight.md) + ship checklist.
4. **iPad / landscape pass** — re-run P0 items in [`../docs/ipad-layout-plan.md`](../docs/ipad-layout-plan.md) (Phase A mostly done 2026-06-17; iPhone landscape attendance confirm still open).
5. **Snapshot baseline re-record** — 71 snapshot failures in CI (pre-existing drift; ~0.25 precision vs 0.98 threshold). Not a reviewer blocker; track in ipad-layout-plan Phase B.

---

## Environment setup

```bash
cd ~/Desktop/personal/League-Keeper-iOS
xcodegen generate            # .xcodeproj is generated, not tracked
```

Then via XcodeBuildMCP (`session_set_defaults`):
- projectPath: `League-Keeper-iOS/League Keeper.xcodeproj`
- scheme: `BudgetLeagueTracker`
- bundleId: `com.jacobrozell.leaguekeeper`
- simulator: iPhone 17 — UDID `22114A58-1110-4FC7-8431-F7B84B6C7465`

Useful: `build_run_sim {}`. Fresh-install test: `xcrun simctl uninstall <UDID> com.jacobrozell.leaguekeeper`.

---

## Acceptance criteria

- Fresh install launches with no crash; full weekly loop completes; all 5 tabs work — on iPhone **and** iPad, portrait **and** landscape.
- All in-app privacy claims match the privacy policy and the Connect nutrition label.
- Support + Privacy links load; donation link correct.
- Migration tests green; UI tests green when Xcode build system is stable.

## Key references

- [AppStoreReviewAudit.md](AppStoreReviewAudit.md) · [`../docs/release/1.0-ship-checklist.md`](../docs/release/1.0-ship-checklist.md) · [`../docs/release/todo.md`](../docs/release/todo.md) · [`backlog.md`](backlog.md)
