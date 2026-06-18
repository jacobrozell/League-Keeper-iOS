import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Tests for TournamentStandingsViewModel
@Suite("TournamentStandingsViewModel Tests", .serialized)
@MainActor
struct TournamentStandingsViewModelTests {
    
    @Suite("refresh")
    @MainActor
    struct RefreshTests {
        
        @Test("Ranks players by tournament game results only")
        func ranksByTournamentResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let first = TestFixtures.player(name: "First", placementPoints: 1, achievementPoints: 0)
            let second = TestFixtures.player(name: "Second", placementPoints: 99, achievementPoints: 0)
            context.insert(first)
            context.insert(second)
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            
            context.insert(TestFixtures.gameResult(
                tournamentId: tournament.id,
                playerId: first.id,
                placement: 1
            ))
            context.insert(TestFixtures.gameResult(
                tournamentId: tournament.id,
                playerId: second.id,
                placement: 4
            ))
            
            let state = try TestHelpers.fetchLeagueState(from: context)!
            state.activeTournamentId = tournament.id
            try context.save()
            
            let viewModel = TournamentStandingsViewModel(context: context)
            
            #expect(viewModel.standings.count == 2)
            #expect(viewModel.standings[0].player.name == "First")
            #expect(viewModel.standings[0].totalPoints == 4)
            #expect(viewModel.standings[1].player.name == "Second")
            #expect(viewModel.standings[1].totalPoints == 1)
        }
        
        @Test("Updates tournament status display")
        func updatesTournamentStatus() throws {
            let context = try TestHelpers.contextWithTournament()
            
            let viewModel = TournamentStandingsViewModel(context: context)
            
            #expect(viewModel.tournamentName == "Test Tournament")
        }
    }
    
    @Suite("close")
    @MainActor
    struct CloseTests {
        
        @Test("Closes standings and returns to tournaments")
        func closesAndReturns() throws {
            let context = try TestHelpers.contextWithTournament()
            let state = try TestHelpers.fetchLeagueState(from: context)!
            state.currentScreen = Screen.tournamentStandings.rawValue
            try context.save()
            
            let viewModel = TournamentStandingsViewModel(context: context)
            viewModel.close()
            
            let updated = try TestHelpers.fetchLeagueState(from: context)
            #expect(updated?.activeTournamentId == nil)
            #expect(updated?.screen == .tournaments)
        }
    }
    
    @Suite("Computed Properties")
    @MainActor
    struct ComputedPropertiesTests {
        
        @Test("standings empty without game results")
        func standingsEmptyWithoutResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentStandingsViewModel(context: context)
            
            #expect(viewModel.standings.isEmpty)
            
            let player = TestFixtures.player()
            context.insert(player)
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            
            let state = try TestHelpers.fetchLeagueState(from: context)!
            state.activeTournamentId = tournament.id
            try context.save()
            
            viewModel.refresh()
            
            #expect(viewModel.standings.isEmpty)
        }
    }
}
