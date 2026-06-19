import SwiftUI
import SwiftData

/// Main entry point for the Budget League Tracker iOS app.
@main
struct BudgetLeagueTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var bootstrap = AppBootstrap()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = bootstrap.container {
                    AppShell()
                        .modelContainer(container)
                } else if bootstrap.failure != nil {
                    BootstrapFailureView(
                        onRetry: { bootstrap.load() },
                        exportURL: bootstrap.exportRecoveryURL()
                    )
                } else {
                    ProgressView("Loading…")
                }
            }
        }
    }
}
