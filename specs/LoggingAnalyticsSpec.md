# Logging & analytics specification

## 1. Principles

- **Privacy first** — no player names, tournament names, or freeform text in remote telemetry.
- **Allowlist only** — only mapped events reach Firebase Analytics.
- **Release only** — Debug and UI tests disable Firebase by default.
- **Unified API** — `AppLog.shared` for console, analytics, and Crashlytics.

---

## 2. Allowlisted analytics events

| Event name | When logged | Parameters |
|------------|-------------|------------|
| `app_open` | App finished launching | `app_version`, `log_category` |
| `tournament_created` | Tournament started | `status`, `weekNumber` (optional) |
| `tournament_completed` | Season finished | `status` |
| `round_recorded` | Pod saved | `weekNumber` |
| `achievement_added` | New achievement in catalog | `source` |

Parameters must be keys in `AnalyticsMetadataKeys.firebaseParameters`.

---

## 3. Crashlytics non-fatal errors

| Event | Code |
|-------|------|
| `model_container_bootstrap_failure` | 1001 |
| `tournament_save_failed` | 1002 |
| `round_save_failed` | 1003 |

---

## 4. Feature flags

| Flag | Release default | Debug default |
|------|-----------------|---------------|
| `enableFirebaseAnalytics` | true (if plist valid) | false |
| `enableFirebaseCrashlytics` | true (if plist valid) | false |

Disabled when: `REPLACE_WITH` in plist, `--uitesting`, `-disable_firebase_analytics`.

---

## 5. Implementation files

- `Support/Logging/AppLogger.swift`, `DefaultAppLogger.swift`
- `FirebaseAnalyticsEventMapping.swift`
- `FirebaseCrashlyticsEventMapping.swift`
- `Bootstrap/FirebaseBootstrap.swift`
- Tests: `FirebaseAnalyticsEventMappingTests.swift`

---

## 6. Change process

1. Add event to mapping allowlist.
2. Add unit test.
3. Update [docs/logging-analytics.md](../docs/logging-analytics.md).
4. Update privacy policy if collection scope changes.
