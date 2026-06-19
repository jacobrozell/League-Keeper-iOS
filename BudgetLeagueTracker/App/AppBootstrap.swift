import Foundation
import SwiftData

/// Loads the SwiftData container and bootstraps default league data.
@Observable
@MainActor
final class AppBootstrap {
    private(set) var container: ModelContainer?
    private(set) var failure: Error?

    init() {
        load()
    }

    func load() {
        failure = nil
        do {
            let newContainer = try LeagueKeeperModelContainer.make()
            Self.bootstrapData(in: newContainer)
            container = newContainer
        } catch {
            AppLog.shared.error(
                .persistence,
                eventName: "model_container_bootstrap_failure",
                message: "Failed to create model container",
                metadata: ["errorDescription": String(describing: error)]
            )
            container = nil
            failure = error
        }
    }

    /// Attempts to export league data from the on-disk store when bootstrap failed.
    func exportRecoveryURL() -> URL? {
        guard let recoveryContainer = try? LeagueKeeperModelContainer.make() else { return nil }
        let context = recoveryContainer.mainContext
        return try? LeagueBackupService.exportURL(context: context)
    }

    private static func bootstrapData(in container: ModelContainer) {
        let context = container.mainContext

        let leagueStateDescriptor = FetchDescriptor<LeagueState>()
        let existingStates = (try? context.fetch(leagueStateDescriptor)) ?? []

        if existingStates.isEmpty {
            context.insert(LeagueState())
        }

        let achievementDescriptor = FetchDescriptor<Achievement>()
        let existingAchievements = (try? context.fetch(achievementDescriptor)) ?? []

        if existingAchievements.isEmpty {
            context.insert(
                Achievement(
                    name: AppConstants.DefaultAchievement.name,
                    points: AppConstants.DefaultAchievement.points,
                    alwaysOn: AppConstants.DefaultAchievement.alwaysOn,
                    achievementDescription: AppConstants.DefaultAchievement.achievementDescription,
                    category: AppConstants.DefaultAchievement.category,
                    iconName: AppConstants.DefaultAchievement.iconName,
                    exclusivity: AppConstants.DefaultAchievement.exclusivity
                )
            )
        }

        _ = PersistenceSave.save(context: context, event: .tournament)
        LeagueEngine.validateAndSanitizeState(context: context)
    }
}
