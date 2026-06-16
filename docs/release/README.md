# Release documentation

Guides for shipping League Keeper to TestFlight and the App Store.

---

## Documents

| Doc | Purpose |
|-----|---------|
| [testflight.md](testflight.md) | Beta distribution setup |
| [1.0-ship-checklist.md](1.0-ship-checklist.md) | Pre-submission gate |
| [todo.md](todo.md) | Open release tasks |

---

## Release train (1.0)

```mermaid
flowchart LR
    Dev[main branch] --> TF[TestFlight internal]
    TF --> Beta[External beta optional]
    Beta --> RC[Release candidate]
    RC --> ASC[App Store review]
    ASC --> Live[Production]
```

| Stage | Gate |
|-------|------|
| TestFlight internal | CI green, app runs on device |
| External beta | Manual VO checklist started |
| App Store submit | [1.0-ship-checklist.md](1.0-ship-checklist.md) complete |

---

## Versioning

- **1.0.0** — First App Store release
- Build number increments every archive upload
- Changelog: [CHANGELOG.md](../../CHANGELOG.md)

---

## Related

- [specs/AppStoreConnectSpec.md](../../specs/AppStoreConnectSpec.md)
- [docs/app-store-listing.md](../app-store-listing.md)
- [docs/ios-roadmap.md](../ios-roadmap.md)
