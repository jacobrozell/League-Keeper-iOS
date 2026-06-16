# GitHub Pages

Static legal and support pages for App Store Connect.

---

## Enable Pages (one-time)

1. Open [github.com/jacobrozell/League-Keeper-iOS/settings/pages](https://github.com/jacobrozell/League-Keeper-iOS/settings/pages)
2. **Build and deployment → Source:** Deploy from a branch
3. **Branch:** `main` · **Folder:** `/docs`
4. Save — site goes live in 1–3 minutes

---

## URLs (after Pages is enabled)

| Page | URL |
|------|-----|
| Home | `https://jacobrozell.github.io/League-Keeper-iOS/` |
| Privacy Policy | `https://jacobrozell.github.io/League-Keeper-iOS/privacy.html` |
| Support | `https://jacobrozell.github.io/League-Keeper-iOS/support.html` |
| Accessibility | `https://jacobrozell.github.io/League-Keeper-iOS/accessibility.html` |

Use **Privacy** and **Support** URLs in App Store Connect. Optional: **Accessibility** under App → App Accessibility.

---

## Source files

| File | Purpose |
|------|---------|
| `docs/index.html` | Landing page |
| `docs/privacy.html` | Hosted privacy policy |
| `docs/support.html` | Support contact + FAQ |
| `docs/accessibility.html` | Accessibility statement |
| `docs/assets/style.css` | Shared styles (light/dark) |

Markdown sources (`privacy-policy.md`, `support.md`) are for editing; HTML is what Pages serves.

---

## Local preview

```bash
python3 -m http.server 8080 --directory docs
# http://localhost:8080/privacy.html
```

---

## Updates

Edit HTML, commit, push — Pages redeploys automatically. Bump "Last updated" dates when practices change (especially Firebase).
