# Logging & analytics

How League Keeper records diagnostics and product-health events.

**Normative spec:** [specs/LoggingAnalyticsSpec.md](../specs/LoggingAnalyticsSpec.md)  
**Code:** `BudgetLeagueTracker/Support/Logging/`

---

## AppLog

All production logging goes through `AppLog.shared` (implements `AppLogger`):

```swift
AppLog.shared.info(
    .scoring,
    eventName: "round_recorded",
    message: "Pod saved",
    metadata: ["weekNumber": "3"]
)
```

### Log levels

`debug` → `info` → `warning` → `error` → `fault`

### Categories

| Category | Use |
|----------|-----|
| `ui` | Navigation, presentation |
| `scoring` | Pods, placements, achievements |
| `persistence` | SwiftData save/load |
| `appLifecycle` | Launch, bootstrap |
| `settings` | User preferences |

### Sinks

| Sink | When active |
|------|-------------|
| `ConsoleLogSink` | Always (OSLog) |
| `FirebaseAnalyticsLogSink` | Release + real plist + flag |
| `FirebaseCrashlyticsLogSink` | Release + real plist + flag |

Debug builds and `--uitesting` disable Firebase collection.

---

## Firebase setup

1. Create Firebase project for `com.budgetleague.BudgetLeagueTracker`.
2. Download `GoogleService-Info.plist` → `Resources/` (gitignored).
3. CI uses `Resources/GoogleService-Info.plist.example`.

---

## Allowlisted analytics events

| Log event | Firebase name | Parameters |
|-----------|---------------|------------|
| `app_bootstrap_ready` | `app_open` | `app_version` |
| `tournament_created` | `tournament_created` | allowlisted keys only |
| `tournament_completed` | `tournament_completed` | |
| `round_recorded` | `round_recorded` | `weekNumber` |
| `achievement_added` | `achievement_added` | |
| `model_container_bootstrap_failure` | (Crashlytics) | `errorCode` |

**Never log:** player names, tournament names, freeform notes.

Mapping: `FirebaseAnalyticsEventMapping.swift` — enforced by unit tests.

---

## Feature flags

| Flag | Default (Release) | Default (Debug) |
|------|-------------------|-----------------|
| `enableFirebaseAnalytics` | on | off |
| `enableFirebaseCrashlytics` | on | off |

Launch args: `-disable_firebase_analytics`, `-firebase_analytics_debug`.

---

## Privacy

Documented in [privacy-policy.md](privacy-policy.md) and [privacy.html](privacy.html). App Store Privacy Nutrition Labels should declare analytics/crash data as collected in Release builds only.

---

## Adding a new event

1. Add event name to allowlist in `FirebaseAnalyticsEventMapping.swift`.
2. Add unit test in `FirebaseAnalyticsEventMappingTests.swift`.
3. Update [specs/LoggingAnalyticsSpec.md](../specs/LoggingAnalyticsSpec.md).
4. Update hosted privacy policy if collection scope changes.
