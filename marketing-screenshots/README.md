# Marketing screenshots

Raw simulator captures and App Store Connect–sized exports.

## Folders

| Path | Contents |
|------|----------|
| `raw/YYYY-MM-DD/` | iPhone simulator PNGs (native resolution) |
| `ipad/raw/YYYY-MM-DD/` | iPad simulator PNGs |
| `asc/YYYY-MM-DD/` | iPhone resized to 1284×2778 |
| `ipad/asc/YYYY-MM-DD/` | iPad resized to 2064×2752 |

## Commands

```bash
# Capture full matrix
DATE_TAG=2026-06-19 ./Scripts/capture-evidence-pack.sh

# Resize for App Store Connect upload
DATE_TAG=2026-06-19 ./Scripts/app-store-screenshot-size.sh
```

See [docs/release/marketing-screenshots-plan.md](../docs/release/marketing-screenshots-plan.md) and [marketing-screenshot-ui-fix-plan.md](../docs/release/marketing-screenshot-ui-fix-plan.md).
