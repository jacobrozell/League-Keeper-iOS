# League Keeper (Budget League Tracker)

League Keeper helps you run and track Magic: The Gathering budget leagues: create tournaments, record attendance and pods, score placement and achievements, and view weekly and final standings.

- **Platform:** iOS 18+, Swift 6, SwiftUI, SwiftData
- **Project:** Xcode project generated from `project.yml` (XcodeGen)

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/architecture.md](docs/architecture.md) | App architecture, data flow, domain concepts, project structure |
| [docs/user-flows.md](docs/user-flows.md) | Main user journeys (create tournament, run week, view results) |
| [docs/development.md](docs/development.md) | Build, run, test, where to make changes |
| [docs/ios-app-plan.md](docs/ios-app-plan.md) | Implementation plan and architecture for the iOS app |
| [docs/ios-roadmap.md](docs/ios-roadmap.md) | Roadmap from build through App Store release and beyond |
| [docs/testing.md](docs/testing.md) | Testing strategy and setup |

### Project structure

- App code lives in **BudgetLeagueTracker/** (Models, Engine, ViewModels, Views, Components, Constants).
- Unit and integration tests in **BudgetLeagueTrackerTests/**; UI tests in **BudgetLeagueTrackerUITests/**.
- See [docs/architecture.md](docs/architecture.md) for details.

### App Store and release

| Document | Description |
|----------|-------------|
| [docs/app-store-listing.md](docs/app-store-listing.md) | **App Store copy** – Ready-to-paste text for App Store Connect: app name, subtitle, description, keywords, What’s New, and promotional text. Use this when filling out the listing and updating it later. |
| [docs/privacy-policy.md](docs/privacy-policy.md) | **Privacy policy** – Source for the required App Store Privacy Policy URL. Host this (e.g. GitHub Pages or your site) and use that URL in App Store Connect. States no server data collection and on-device-only storage. |
| [docs/support.md](docs/support.md) | **Support page** – Source for the required App Store Support URL. Host this and add your contact or GitHub Issues link; then use the hosted URL in App Store Connect. |

Before submitting to the App Store, host the privacy policy and support pages and replace any placeholders in those files with your real URLs and contact details.

---

## Building and running

1. Generate the Xcode project (if using XcodeGen): `xcodegen` from the project root.
2. Open `BudgetLeagueTracker.xcodeproj` in Xcode.
3. Select a simulator or device and run (⌘R).

---

## License

See the project’s license file if present. Copyright as in `project.yml`.
