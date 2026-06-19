import Foundation
import SwiftData

/// Sort options for the players list.
enum PlayerSortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case points = "Points"
    case wins = "Wins"
    case games = "Games"
    case recent = "Recent"

    var id: String { rawValue }

    private static let sortPreferenceKey = "playersSortOption"

    static func loadSavedSort() -> PlayerSortOption {
        guard let raw = UserDefaults.standard.string(forKey: sortPreferenceKey),
              let option = PlayerSortOption(rawValue: raw) else {
            return .points
        }
        return option
    }

    func save() {
        UserDefaults.standard.set(rawValue, forKey: Self.sortPreferenceKey)
    }
}

/// Result of attempting to add a player.
enum AddPlayerResult {
    case added(Player)
    case validationError(String)
}

/// ViewModel for the Players view.
/// Manages player list display, search, sort, and adding new players.
@MainActor
@Observable
final class PlayersViewModel {
    private let context: ModelContext

    // MARK: - Published State

    var players: [Player] = []
    var gameResults: [GameResult] = []
    var newPlayerName: String = ""
    var newPlayerNote: String = ""
    var isShowingAddPlayerSheet: Bool = false
    var searchText: String = ""
    var sortOption: PlayerSortOption = PlayerSortOption.loadSavedSort()
    var pendingToastMessage: String?

    // MARK: - Computed Properties

    var hasPlayers: Bool {
        !players.isEmpty
    }

    var canAddPlayer: Bool {
        !newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var addPlayerValidationError: String? {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return PlayerNameValidation.validate(name: trimmed)
    }

    var duplicateNameHint: String? {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        guard PlayerNameValidation.hasSameName(context: context, name: trimmed) else { return nil }
        if !newPlayerNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return nil }
        return "Another \(trimmed) is on the roster. Add a nickname to tell them apart."
    }

    private var leagueRanks: [String: Int] {
        StatsEngine.leagueRanks(players: players)
    }

    var filteredPlayers: [Player] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var list = players
        if !query.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }

        switch sortOption {
        case .name:
            return list.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .points:
            return list.sorted {
                if $0.totalPoints != $1.totalPoints { return $0.totalPoints > $1.totalPoints }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .wins:
            return list.sorted {
                if $0.wins != $1.wins { return $0.wins > $1.wins }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .games:
            return list.sorted {
                if $0.gamesPlayed != $1.gamesPlayed { return $0.gamesPlayed > $1.gamesPlayed }
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .recent:
            return list.sorted { lhs, rhs in
                let lhsDate = StatsEngine.lastPlayedDate(playerId: lhs.id, results: gameResults) ?? .distantPast
                let rhsDate = StatsEngine.lastPlayedDate(playerId: rhs.id, results: gameResults) ?? .distantPast
                if lhsDate != rhsDate { return lhsDate > rhsDate }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
        }
    }

    // MARK: - Initialization

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    // MARK: - Actions

    /// Refreshes player data from SwiftData.
    func refresh() {
        let descriptor = FetchDescriptor<Player>(
            sortBy: [SortDescriptor(\.name)]
        )
        players = (try? context.fetch(descriptor)) ?? []
        gameResults = StatsEngine.fetchAllResults(context: context)
    }

    /// Adds a new player with the current name.
    @discardableResult
    func addPlayer() -> AddPlayerResult {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = PlayerNameValidation.validate(name: trimmed) {
            return .validationError(error)
        }
        let note = newPlayerNote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let player = LeagueEngine.addPlayer(
            context: context,
            name: trimmed,
            nameNote: note.isEmpty ? nil : note
        ) else {
            return .validationError(PersistenceError.saveFailed.toastMessage)
        }
        newPlayerName = ""
        newPlayerNote = ""
        refresh()
        pendingToastMessage = "\(displayName(for: player)) added"
        return .added(player)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: players)
    }

    func consumePendingToast() -> String? {
        defer { pendingToastMessage = nil }
        return pendingToastMessage
    }

    func rank(for player: Player) -> Int? {
        leagueRanks[player.id]
    }

    func recentPlacements(for player: Player) -> [Int] {
        StatsEngine.recentPlacements(playerId: player.id, results: gameResults)
    }

    func sparklinePoints(for player: Player) -> [Double] {
        StatsEngine.sparklinePoints(playerId: player.id, results: gameResults)
    }

    /// Returns a subtitle string for a player showing key stats.
    func subtitle(for player: Player) -> String {
        let parts: [String] = [
            "\(player.totalPoints) pts",
            "\(player.gamesPlayed) games",
            "\(player.wins) wins"
        ]
        return parts.joined(separator: " • ")
    }

    func updateSortOption(_ option: PlayerSortOption) {
        sortOption = option
        option.save()
    }
}
