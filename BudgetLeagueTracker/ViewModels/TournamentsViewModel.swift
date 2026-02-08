import Foundation
import SwiftData

/// ViewModel for the Tournaments view.
/// Manages tournament list display and navigation.
@Observable
final class TournamentsViewModel {
    private let context: ModelContext
    
    // MARK: - Published State
    
    var ongoingTournaments: [Tournament] = []
    var completedTournaments: [Tournament] = []
    var players: [Player] = []
    
    /// Tournament being edited (nil when sheet is dismissed).
    var editingTournament: Tournament?
    /// Tournament pending delete confirmation.
    var tournamentToDelete: Tournament?
    /// Completed tournament whose standings are shown in a sheet (nil when sheet dismissed).
    var completedTournamentForSheet: Tournament?
    var editName: String = ""
    var editWeeks: Int = AppConstants.League.defaultTotalWeeks
    var editRandomPerWeek: Int = AppConstants.League.defaultRandomAchievementsPerWeek
    
    // MARK: - Computed Properties
    
    var hasOngoingTournaments: Bool {
        !ongoingTournaments.isEmpty
    }
    
    var hasCompletedTournaments: Bool {
        !completedTournaments.isEmpty
    }
    
    var hasTournaments: Bool {
        hasOngoingTournaments || hasCompletedTournaments
    }
    
    // MARK: - Initialization
    
    init(context: ModelContext) {
        self.context = context
        refresh()
    }
    
    // MARK: - Actions
    
    /// Refreshes tournament data from SwiftData.
    func refresh() {
        // Fetch all tournaments
        let tournamentDescriptor = FetchDescriptor<Tournament>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let allTournaments = (try? context.fetch(tournamentDescriptor)) ?? []
        
        // Split by status
        ongoingTournaments = allTournaments.filter { $0.status == .ongoing }
        completedTournaments = allTournaments.filter { $0.status == .completed }
        
        // Fetch all players for counts and winner lookup
        let playerDescriptor = FetchDescriptor<Player>(sortBy: [SortDescriptor(\.name)])
        players = (try? context.fetch(playerDescriptor)) ?? []
    }
    
    /// Returns the number of players who participated in a tournament.
    /// For ongoing tournaments, returns present player count.
    /// For completed tournaments, queries GameResults.
    func playerCount(for tournament: Tournament) -> Int {
        if tournament.status == .ongoing {
            return tournament.presentPlayerIds.count
        }
        
        // For completed tournaments, count unique players from GameResults
        let descriptor = FetchDescriptor<GameResult>()
        let allResults = (try? context.fetch(descriptor)) ?? []
        let results = allResults.filter { $0.tournamentId == tournament.id }
        let uniquePlayerIds = Set(results.map { $0.playerId })
        return uniquePlayerIds.count
    }
    
    /// Returns the winner's name for a completed tournament.
    /// The winner is the player with the most total points in that tournament's GameResults.
    func winnerName(for tournament: Tournament) -> String? {
        guard tournament.status == .completed else { return nil }
        
        let descriptor = FetchDescriptor<GameResult>()
        let allResults = (try? context.fetch(descriptor)) ?? []
        let results = allResults.filter { $0.tournamentId == tournament.id }
        
        guard !results.isEmpty else { return nil }
        
        // Sum points per player
        var pointsByPlayer: [String: Int] = [:]
        for result in results {
            pointsByPlayer[result.playerId, default: 0] += result.totalPoints
        }
        
        // Find player with most points
        guard let winnerId = pointsByPlayer.max(by: { $0.value < $1.value })?.key,
              let winner = players.first(where: { $0.id == winnerId }) else {
            return nil
        }
        
        return winner.name
    }
    
    /// Presents the new tournament sheet (single-screen create, like React modal).
    var showNewTournamentSheet: Bool = false
    var newTournamentSheetViewModel: NewTournamentViewModel?
    
    /// Opens the new tournament sheet instead of pushing a screen.
    func createNewTournament() {
        let vm = NewTournamentViewModel(context: context)
        vm.isSheetMode = true
        newTournamentSheetViewModel = vm
        showNewTournamentSheet = true
    }
    
    /// Dismisses the new tournament sheet and refreshes the list.
    func dismissNewTournamentSheet() {
        showNewTournamentSheet = false
        newTournamentSheetViewModel = nil
        refresh()
    }
    
    /// Sets a tournament as the active tournament (for context when navigating).
    /// Navigation is now handled by SwiftUI NavigationLink to TournamentDetailView.
    func setActiveTournament(_ tournament: Tournament) {
        guard let state = LeagueEngine.fetchLeagueState(context: context) else { return }
        state.activeTournamentId = tournament.id
        try? context.save()
    }
    
    /// Opens the edit sheet for the given tournament.
    func openEdit(_ tournament: Tournament) {
        editingTournament = tournament
        editName = tournament.name
        editWeeks = tournament.totalWeeks
        editRandomPerWeek = tournament.randomAchievementsPerWeek
    }
    
    /// Saves the current edit and dismisses the sheet.
    func saveEdit() {
        guard let tournament = editingTournament else { return }
        LeagueEngine.updateTournament(
            context: context,
            id: tournament.id,
            name: editName,
            totalWeeks: editWeeks,
            randomPerWeek: editRandomPerWeek
        )
        editingTournament = nil
        refresh()
    }
    
    /// Requests delete confirmation for the given tournament.
    func requestDelete(_ tournament: Tournament) {
        tournamentToDelete = tournament
    }
    
    /// Confirms and performs the delete, then clears the pending tournament.
    func confirmDelete() {
        guard let tournament = tournamentToDelete else { return }
        LeagueEngine.deleteTournament(context: context, id: tournament.id)
        tournamentToDelete = nil
        refresh()
    }
    
    /// Opens the standings sheet for a completed tournament (stays on list).
    func openCompletedStandings(_ tournament: Tournament) {
        setActiveTournament(tournament)
        completedTournamentForSheet = tournament
    }
    
    /// Dismisses the completed standings sheet.
    func closeCompletedStandingsSheet() {
        completedTournamentForSheet = nil
    }
}
