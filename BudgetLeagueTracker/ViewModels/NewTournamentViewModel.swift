import Foundation
import SwiftData

/// ViewModel for the New Tournament view.
/// Handles tournament creation with name, settings, and player selection.
@MainActor
@Observable
final class NewTournamentViewModel {
    private let context: ModelContext

    // MARK: - Published State
    
    /// Tournament name (required)
    var tournamentName: String = ""
    
    /// Total weeks in the tournament
    var totalWeeks: Int = AppConstants.League.defaultTotalWeeks
    
    /// Random achievements per week
    var randomAchievementsPerWeek: Int = AppConstants.League.defaultRandomAchievementsPerWeek

    /// When true, rounds 2–3 seat by previous-round finish instead of random.
    var standingsBasedSeating: Bool = AppConstants.League.defaultStandingsBasedSeating

    /// Selected league preset (defaults to simple league).
    var selectedPreset: LeaguePreset = .simpleLeague {
        didSet {
            guard selectedPreset != oldValue else { return }
            rules = selectedPreset.defaultRules()
        }
    }

    /// Players seated at each table for this tournament.
    var playersPerTable: Int = AppConstants.League.defaultPlayersPerTable

    /// Placement point scale preset.
    var placementScalePreset: PlacementScalePreset = .standard

    /// Deck, prize, and playstyle rules for the new tournament.
    var rules: TournamentRules = LeaguePreset.simpleLeague.defaultRules()
    
    /// All existing players
    var allPlayers: [Player] = []
    
    /// IDs of selected players for this tournament
    var selectedPlayerIds: Set<String> = []
    
    /// Name for adding a new player
    var newPlayerName: String = ""

    /// Search filter for the player roster
    var searchText: String = ""
    
    /// When true, Create stays on tournaments list (dismiss sheet) instead of navigating to attendance.
    var isSheetMode: Bool = false

    private(set) var persistenceErrorMessage: String?
    
    // MARK: - Computed Properties
    
    /// Whether the tournament can be created (has name and at least one player)
    var canCreateTournament: Bool {
        !tournamentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedPlayerIds.isEmpty
    }
    
    /// Whether a new player can be added
    var canAddPlayer: Bool {
        !newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Number of selected players
    var selectedPlayerCount: Int {
        selectedPlayerIds.count
    }

    /// Players shown in the roster, filtered by search text.
    var filteredPlayers: [Player] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allPlayers }
        return allPlayers.filter {
            displayName(for: $0).localizedCaseInsensitiveContains(query)
                || $0.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Initialization
    
    init(context: ModelContext) {
        self.context = context
        refresh()
    }
    
    // MARK: - Actions
    
    /// Refreshes player list from SwiftData. Does not change selection (preserves user toggles).
    func refresh() {
        let descriptor = FetchDescriptor<Player>(sortBy: [SortDescriptor(\.name)])
        allPlayers = (try? context.fetch(descriptor)) ?? []
    }

    /// Applies a league preset, resetting rules to preset defaults.
    func applyPreset(_ preset: LeaguePreset) {
        selectedPreset = preset
        rules = preset.defaultRules()
    }
    
    /// Toggles player selection.
    func togglePlayer(_ player: Player) {
        if selectedPlayerIds.contains(player.id) {
            selectedPlayerIds.remove(player.id)
        } else {
            selectedPlayerIds.insert(player.id)
        }
    }
    
    /// Returns whether a player is selected.
    func isSelected(_ player: Player) -> Bool {
        selectedPlayerIds.contains(player.id)
    }
    
    /// Selects all players.
    func selectAll() {
        selectedPlayerIds = Set(allPlayers.map { $0.id })
    }
    
    /// Deselects all players.
    func deselectAll() {
        selectedPlayerIds.removeAll()
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: allPlayers)
    }
    
    /// Adds a new player and selects them.
    func addPlayer() {
        guard canAddPlayer else { return }
        
        if let player = LeagueEngine.addPlayer(context: context, name: newPlayerName) {
            selectedPlayerIds.insert(player.id)
            newPlayerName = ""
            refresh()
        }
    }
    
    /// Creates the tournament. When isSheetMode is false, navigates to attendance; when true, stays on list (caller dismisses sheet).
    @discardableResult
    func createTournament() -> Bool {
        guard canCreateTournament else { return false }
        
        let trimmedName = tournamentName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard LeagueEngine.createTournament(
            context: context,
            name: trimmedName,
            totalWeeks: totalWeeks,
            randomPerWeek: randomAchievementsPerWeek,
            playerIds: Array(selectedPlayerIds),
            presentAttendance: !isSheetMode,
            standingsBasedSeating: standingsBasedSeating,
            rules: rules,
            leaguePreset: selectedPreset,
            playersPerTable: playersPerTable,
            placementPointsScale: placementScalePreset.scale
        ) else {
            persistenceErrorMessage = PersistenceError.saveFailed.toastMessage
            return false
        }
        return true
    }

    func clearPersistenceError() {
        persistenceErrorMessage = nil
    }
    
    /// Cancels and returns to tournaments list.
    func cancel() {
        LeagueEngine.setScreen(context: context, screen: .tournaments)
    }
}
