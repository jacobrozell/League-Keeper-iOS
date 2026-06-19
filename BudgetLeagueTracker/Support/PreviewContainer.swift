import SwiftData

/// Shared in-memory container for SwiftUI previews.
@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let container = try! LeagueKeeperModelContainer.make(isStoredInMemoryOnly: true)

        let context = container.mainContext
        context.insert(LeagueState())
        context.insert(
            Achievement(
                name: AppConstants.DefaultAchievement.name,
                points: AppConstants.DefaultAchievement.points,
                alwaysOn: AppConstants.DefaultAchievement.alwaysOn
            )
        )

        return container
    }()
}
