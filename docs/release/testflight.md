# TestFlight guide

How to distribute League Keeper betas before App Store release.

---

## Prerequisites

- Apple Developer Program membership
- App record created in [App Store Connect](https://appstoreconnect.apple.com)
- Bundle ID `com.jacobrozell.leaguekeeper` registered
- Signing certificate + provisioning profile (Automatic signing in Xcode)

---

## Option A: Xcode (manual)

1. Open `BudgetLeagueTracker.xcodeproj` (run `xcodegen` first).
2. Select **Any iOS Device** or connected device.
3. **Product → Archive**.
4. In Organizer → **Distribute App** → **App Store Connect** → Upload.
5. In App Store Connect → **TestFlight** → add internal testers.

### Before archiving

- [ ] Real `GoogleService-Info.plist` in `Resources/` (optional for beta analytics)
- [ ] `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` bumped in `project.yml` → `xcodegen`
- [ ] App icon present in `Assets.xcassets`
- [ ] CI green on `main`

---

## Option B: Xcode Cloud (recommended next step)

Mirror Dart Buddy's pipeline:

1. Connect repo in Xcode Cloud.
2. Create **Release** workflow: archive + TestFlight upload.
3. Optional: GHA workflow to trigger Xcode Cloud via App Store Connect API.

Document workflow IDs in this file when configured.

---

## Beta testing focus

| Area | Testers should verify |
|------|----------------------|
| Core flow | Create tournament → 3 rounds → standings |
| Edge cases | Odd player counts, undo pod, edit round |
| Devices | iPhone + iPad, light + dark |
| Accessibility | VoiceOver on create tournament + pod scoring |

File bugs in [GitHub Issues](https://github.com/jacobrozell/League-Keeper-iOS/issues).

---

## Crash monitoring

Release/TestFlight builds with Firebase configured will report to Crashlytics. Monitor during beta week before App Store submit.

---

## Promoting to App Store

Complete [1.0-ship-checklist.md](1.0-ship-checklist.md), then submit the tested build for review in App Store Connect.

---

## Related

- [AppStoreConnectSpec.md](../../specs/AppStoreConnectSpec.md)
- [infrastructure.md](../infrastructure.md)
