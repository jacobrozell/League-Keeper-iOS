# Dynamic Type (AXXXL) evidence

Manual screenshots for WCAG P-1.4.4 sign-off.

## Checklist

- [ ] Onboarding page 4 — single primary CTA, readable at AXXXL
- [ ] New tournament form
- [ ] Tournament detail — attendance, seating, scoring
- [ ] Stats — segments and charts
- [ ] Achievements list

## Code adaptations (2026-06-18)

- List rows scale to AXXXL (`TournamentCell`, `PlayerRow`, `StandingsRow`)
- `EmptyStateView` scales to AXXXL
- `StatTile` reflow at accessibility sizes
- Progress header collapsible at accessibility sizes
- Segmented controls → menu pickers at large text

## Capture

Device or Simulator → Settings → Accessibility → Display & Text Size → Larger Text → enable Larger Accessibility Sizes → AXXXL.

Save PNGs here as `YYYY-MM-DD-<screen>-axxxl.png`.
