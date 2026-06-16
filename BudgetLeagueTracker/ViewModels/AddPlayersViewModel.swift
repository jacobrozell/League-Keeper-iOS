import Foundation
import SwiftData

/// ViewModel for the Add Players view.
/// Manages player list and league settings before starting the tournament.
@Observable
final class AddPlayersViewModel {
    private let context: ModelContext
    
    // MARK: - Published State
    
    var players: [Player] = []
    var totalWeeks: Int = AppConstants.League.defaultTotalWeeks
    var randomAchievementsPerWeek: Int = AppConstants.League.defaultRandomAchievementsPerWeek
    var newPlayerName: String = ""
    
    var canStartTournament: Bool {
        !players.isEmpty
    }
    
    // MARK: - Initialization
    
    init(context: ModelContext) {
        self.context = context
        refresh()
    }
    
    // MARK: - Actions
    
    /// Refreshes state from SwiftData.
    func refresh() {
        let descriptor = FetchDescriptor<Player>(sortBy: [SortDescriptor(\.name)])
        players = (try? context.fetch(descriptor)) ?? []
        
        // Use defaults - this view is for legacy flow
        totalWeeks = AppConstants.League.defaultTotalWeeks
        randomAchievementsPerWeek = AppConstants.League.defaultRandomAchievementsPerWeek
    }
    
    /// Adds a new player with the current name.
    func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard PlayerNameValidation.validate(name: trimmed) == nil else { return }
        guard LeagueEngine.addPlayer(context: context, name: trimmed) != nil else { return }
        newPlayerName = ""
        refresh()
    }
    
    /// Removes a player by ID.
    func removePlayer(_ player: Player) {
        LeagueEngine.removePlayer(context: context, id: player.id)
        refresh()
    }
    
    /// Starts the tournament with current settings.
    func startTournament() {
        guard canStartTournament else { return }
        
        // Create tournament with all players
        let playerIds = players.map { $0.id }
        LeagueEngine.createTournament(
            context: context,
            name: "Tournament",
            totalWeeks: totalWeeks,
            randomPerWeek: randomAchievementsPerWeek,
            playerIds: playerIds
        )
    }
    
    /// Cancels and returns to tournaments list.
    func cancel() {
        LeagueEngine.setScreen(context: context, screen: .tournaments)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: players)
    }
}
