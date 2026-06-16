# Tech stack specification

## Languages & platforms

| Item | Version / note |
|------|----------------|
| Swift | 6.0, strict concurrency |
| iOS deployment target | 18.0 |
| Devices | iPhone, iPad (universal) |
| Xcode | 16+ (CI uses 26.2) |

---

## UI & persistence

| Technology | Use |
|------------|-----|
| SwiftUI | All UI |
| SwiftData | `@Model` persistence |
| Charts | Stats visualizations |

---

## Build & project

| Tool | Use |
|------|-----|
| XcodeGen | `project.yml` → `.xcodeproj` |
| SPM | ViewInspector, SnapshotTesting, Firebase |

---

## Quality & ops

| Tool | Use |
|------|-----|
| SwiftLint | PR lint gate |
| GitHub Actions | CI + nightly UI |
| Firebase | Analytics + Crashlytics (Release) |
| GitHub Pages | Legal/support hosting |

---

## Not in v1.0

- Fastlane
- SwiftFormat (optional locally)
- Localization
- CloudKit / iCloud
- Widgets / App Intents

---

## Dependencies (SPM)

```yaml
# project.yml
ViewInspector: 0.10.0+
SnapshotTesting: 1.15.0+
Firebase iOS SDK: 11.0.0+
```

---

## Related

- [docs/development.md](../docs/development.md)
- [docs/infrastructure.md](../docs/infrastructure.md)
