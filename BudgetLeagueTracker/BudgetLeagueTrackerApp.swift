import SwiftUI
import SwiftData

/// Main entry point for the Budget League Tracker iOS app.
@main
struct BudgetLeagueTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let modelContainer: ModelContainer

    init() {
        do {
            let container = try LeagueKeeperModelContainer.make()
            Self.bootstrapData(in: container)
            modelContainer = container
        } catch {
            AppLog.shared.error(
                .persistence,
                eventName: "model_container_bootstrap_failure",
                message: "Failed to create model container",
                metadata: ["errorCode": String(describing: type(of: error))]
            )
            modelContainer = try! LeagueKeeperModelContainer.make(isStoredInMemoryOnly: true)
            Self.bootstrapData(in: modelContainer)
        }
    }

    var body: some Scene {
        WindowGroup {
            AppShell()
        }
        .modelContainer(modelContainer)
    }
    
    /// Bootstrap initial data if needed.
    /// Creates default LeagueState, seeds the default achievement, and validates state.
    private static func bootstrapData(in container: ModelContainer) {
        let context = container.mainContext
        
        // Ensure exactly one LeagueState exists
        let leagueStateDescriptor = FetchDescriptor<LeagueState>()
        let existingStates = (try? context.fetch(leagueStateDescriptor)) ?? []
        
        if existingStates.isEmpty {
            let defaultState = LeagueState()
            context.insert(defaultState)
        }
        
        // Seed default achievement if none exist
        let achievementDescriptor = FetchDescriptor<Achievement>()
        let existingAchievements = (try? context.fetch(achievementDescriptor)) ?? []
        
        if existingAchievements.isEmpty {
            let defaultAchievement = Achievement(
                name: AppConstants.DefaultAchievement.name,
                points: AppConstants.DefaultAchievement.points,
                alwaysOn: AppConstants.DefaultAchievement.alwaysOn,
                achievementDescription: AppConstants.DefaultAchievement.achievementDescription,
                category: AppConstants.DefaultAchievement.category,
                iconName: AppConstants.DefaultAchievement.iconName,
                exclusivity: AppConstants.DefaultAchievement.exclusivity
            )
            context.insert(defaultAchievement)
        }
        
        // Save changes
        try? context.save()
        
        // Validate and sanitize state to fix any inconsistencies
        LeagueEngine.validateAndSanitizeState(context: context)
    }
}
