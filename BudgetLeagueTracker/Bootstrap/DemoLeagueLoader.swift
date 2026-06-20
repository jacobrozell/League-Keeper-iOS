import Foundation
import SwiftData

/// Seeds a sample league so new users can explore the app without manual setup.
@MainActor
enum DemoLeagueLoader {
    static let tournamentName = "Weekly Game Night"
    static let playerNames = [
        "Alice", "Bob", "Carol", "Dave",
        "Eve", "Frank", "Grace", "Henry",
    ]

    struct LoadResult: Sendable {
        let playerCount: Int
        let tournamentName: String
        let tournamentId: String
    }

    @discardableResult
    static func load(into context: ModelContext) throws -> LoadResult {
        guard fetchOngoingTournaments(in: context).isEmpty else {
            throw LoadError.alreadyHasData
        }

        let playerIds = playerNames.compactMap { name in
            LeagueEngine.addPlayer(context: context, name: name)?.id
        }
        guard playerIds.count >= AppConstants.League.defaultPlayersPerTable else {
            throw LoadError.insufficientPlayers
        }

        seedSampleAchievements(in: context)

        LeagueEngine.createTournament(
            context: context,
            name: tournamentName,
            totalWeeks: AppConstants.League.defaultTotalWeeks,
            randomPerWeek: AppConstants.League.defaultRandomAchievementsPerWeek,
            playerIds: playerIds,
            presentAttendance: false,
            rules: LeaguePreset.simpleLeague.defaultRules(),
            leaguePreset: .simpleLeague
        )

        guard let tournament = fetchOngoingTournaments(in: context).first(where: { $0.name == tournamentName }) else {
            throw LoadError.tournamentNotFound
        }

        LeagueEngine.setScreen(context: context, screen: .tournaments)
        try context.save()

        return LoadResult(
            playerCount: playerIds.count,
            tournamentName: tournamentName,
            tournamentId: tournament.id
        )
    }

    enum LoadError: LocalizedError {
        case alreadyHasData
        case insufficientPlayers
        case tournamentNotFound

        var errorDescription: String? {
            switch self {
            case .alreadyHasData:
                return "Sample league wasn’t loaded because you already have tournaments."
            case .insufficientPlayers:
                return "Couldn’t create a sample league with enough players."
            case .tournamentNotFound:
                return "Sample league was created but the tournament couldn’t be opened."
            }
        }
    }

    private static func fetchOngoingTournaments(in context: ModelContext) -> [Tournament] {
        let descriptor = FetchDescriptor<Tournament>(
            predicate: #Predicate { $0.statusRaw == "ongoing" }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private static func seedSampleAchievements(in context: ModelContext) {
        let samples = AchievementTemplates.templates(for: .generic).filter {
            $0.name == "Good Sport" || $0.name == "MVP"
        }

        let existing = LeagueEngine.fetchAllAchievements(context: context)
        let existingNames = Set(existing.map(\.name))

        for template in samples where !existingNames.contains(template.name) {
            _ = LeagueEngine.addAchievement(
                context: context,
                name: template.name,
                points: template.points,
                alwaysOn: template.alwaysOn,
                achievementDescription: template.achievementDescription,
                category: template.category,
                iconName: template.iconName,
                exclusivity: template.exclusivity
            )
        }
    }
}
