import Foundation
import SwiftData

/// Seeds SwiftData for UI tests when launch arguments request a scenario.
/// Avoids flaky New Tournament form automation on iOS 26 simulators.
@MainActor
enum UITestBootstrap {
    static let tournamentName = "UI Test League"
    static let playerNames = ["Alice", "Bob", "Carol", "Dave"]

    static let seedAttendance = "UI-Testing-Seed-Attendance"
    static let seedTournamentDetail = "UI-Testing-Seed-TournamentDetail"
    static let seedEditRound = "UI-Testing-Seed-EditRound"

    /// When set, `ContentView` should push this tournament onto the tournaments navigation stack.
    private(set) static var pendingTournamentNavigationName: String?

    /// Applies UI-test seed data once per launch. Call from `ContentView.onAppear` so seeding
    /// completes before XCUITest interacts with the UI.
    static func applyIfNeeded(context: ModelContext) {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("--uitesting") else { return }

        let scenario: Scenario?
        if arguments.contains(seedAttendance) {
            scenario = .attendance
        } else if arguments.contains(seedTournamentDetail) {
            scenario = .tournamentDetail
        } else if arguments.contains(seedEditRound) {
            scenario = .editRound
        } else {
            scenario = nil
        }

        guard let scenario else { return }
        pendingTournamentNavigationName = nil
        seed(scenario, in: context)
    }

    /// Opens a seeded tournament detail screen when launch args request it.
    static func openPendingTournamentDetailIfNeeded(
        context: ModelContext,
        navigationPath: inout [Tournament]
    ) {
        guard let name = pendingTournamentNavigationName else { return }
        pendingTournamentNavigationName = nil

        let descriptor = FetchDescriptor<Tournament>(
            predicate: #Predicate { $0.name == name && $0.statusRaw == "ongoing" }
        )
        guard let tournament = try? context.fetch(descriptor).first else { return }
        navigationPath = [tournament]
    }

    // MARK: - Scenarios

    private enum Scenario {
        case attendance
        case tournamentDetail
        case editRound
    }

    private static func seed(_ scenario: Scenario, in context: ModelContext) {
        resetUITestData(in: context)

        let playerIds = insertPlayers(in: context)
        guard !playerIds.isEmpty else { return }

        LeagueEngine.createTournament(
            context: context,
            name: tournamentName,
            totalWeeks: AppConstants.League.defaultTotalWeeks,
            randomPerWeek: AppConstants.League.defaultRandomAchievementsPerWeek,
            playerIds: playerIds,
            presentAttendance: true
        )

        switch scenario {
        case .attendance:
            setScreen(.attendance, in: context)
        case .tournamentDetail:
            confirmAttendance(in: context, playerIds: playerIds)
            setScreen(.tournaments, in: context)
            pendingTournamentNavigationName = tournamentName
        case .editRound:
            confirmAttendance(in: context, playerIds: playerIds)
            seedPodsForCurrentRound(in: context)
            LeagueEngine.nextRound(context: context)
            seedPodsForCurrentRound(in: context)
            setScreen(.tournaments, in: context)
            pendingTournamentNavigationName = tournamentName
        }
    }

    // MARK: - Helpers

    private static func resetUITestData(in context: ModelContext) {
        deleteAll(GameResult.self, in: context)
        deleteAll(Tournament.self, in: context)
        deleteAll(Player.self, in: context)

        if let state = LeagueEngine.fetchLeagueState(context: context) {
            state.activeTournamentId = nil
            state.screen = .tournaments
        }

        try? context.save()
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) {
        let descriptor = FetchDescriptor<T>()
        let items = (try? context.fetch(descriptor)) ?? []
        for item in items {
            context.delete(item)
        }
    }

    private static func insertPlayers(in context: ModelContext) -> [String] {
        playerNames.compactMap { name in
            LeagueEngine.addPlayer(context: context, name: name)?.id
        }
    }

    private static func confirmAttendance(in context: ModelContext, playerIds: [String]) {
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: playerIds,
            achievementsOnThisWeek: true
        )
    }

    private static func seedPodsForCurrentRound(in context: ModelContext) {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return }

        let allPlayers = (try? context.fetch(FetchDescriptor<Player>())) ?? []
        let pods = LeagueEngine.generatePodsForRound(
            players: allPlayers,
            presentPlayerIds: tournament.presentPlayerIds,
            currentRound: tournament.currentRound,
            weeklyPointsByPlayer: tournament.weeklyPointsByPlayer
        )

        LeagueEngine.clearRoundData(context: context)
        for pod in pods {
            for (index, player) in pod.enumerated() {
                LeagueEngine.updatePlacement(
                    context: context,
                    playerId: player.id,
                    placement: min(index + 1, 4)
                )
            }
        }
    }

    private static func setScreen(_ screen: Screen, in context: ModelContext) {
        LeagueEngine.setScreen(context: context, screen: screen)
    }
}
