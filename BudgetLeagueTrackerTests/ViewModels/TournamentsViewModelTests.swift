import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Tests for TournamentsViewModel
@Suite("TournamentsViewModel Tests", .serialized)
@MainActor
struct TournamentsViewModelTests {
    
    @Suite("refresh")
    @MainActor
    struct RefreshTests {
        
        @Test("Loads ongoing and completed tournaments separately")
        func loadsTournamentsBySeparately() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            // Create ongoing tournament
            let ongoing = TestFixtures.tournament(name: "Ongoing")
            context.insert(ongoing)
            
            // Create completed tournament
            let completed = TestFixtures.completedTournament()
            context.insert(completed)
            
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            
            #expect(viewModel.ongoingTournaments.count == 1)
            #expect(viewModel.completedTournaments.count == 1)
            #expect(viewModel.ongoingTournaments.first?.name == "Ongoing")
            #expect(viewModel.completedTournaments.first?.name == "Completed Tournament")
        }
        
        @Test("Loads players for counts")
        func loadsPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            TestFixtures.insertStandardPlayers(into: context)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            
            #expect(viewModel.players.count == 4)
        }
    }
    
    @Suite("playerCount")
    @MainActor
    struct PlayerCountTests {
        
        @Test("Returns present player count for ongoing tournament")
        func returnsCountForOngoing() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let tournament = TestFixtures.tournament()
            tournament.presentPlayerIds = ["p1", "p2", "p3"]
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            let count = viewModel.playerCount(for: tournament)
            
            #expect(count == 3)
        }
        
        @Test("Returns unique player count from GameResults for completed")
        func returnsCountForCompleted() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            
            // Create game results
            let result1 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: "p1", placement: 1)
            let result2 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: "p2", placement: 2)
            let result3 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: "p1", placement: 1) // duplicate player
            context.insert(result1)
            context.insert(result2)
            context.insert(result3)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            let count = viewModel.playerCount(for: tournament)
            
            #expect(count == 2) // p1 and p2
        }
    }
    
    @Suite("winnerName")
    @MainActor
    struct WinnerNameTests {
        
        @Test("Returns winner name for completed tournament")
        func returnsWinnerName() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let winner = TestFixtures.player(name: "Winner")
            let loser = TestFixtures.player(name: "Loser")
            context.insert(winner)
            context.insert(loser)
            
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            
            // Winner has more points
            let result1 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: winner.id, placement: 1) // 4 pts
            let result2 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: loser.id, placement: 4)  // 1 pt
            context.insert(result1)
            context.insert(result2)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            let name = viewModel.winnerName(for: tournament)
            
            #expect(name == "Winner")
        }
        
        @Test("Returns nil for ongoing tournament")
        func returnsNilForOngoing() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament() // ongoing by default
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            let name = viewModel.winnerName(for: tournament)
            
            #expect(name == nil)
        }
    }
    
    @Suite("createNewTournament")
    @MainActor
    struct CreateNewTournamentTests {
        
        @Test("Opens new tournament sheet instead of setting screen")
        func opensNewTournamentSheet() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentsViewModel(context: context)
            
            viewModel.createNewTournament()
            
            #expect(viewModel.showNewTournamentSheet == true)
            #expect(viewModel.newTournamentSheetViewModel != nil)
            #expect(viewModel.newTournamentSheetViewModel?.isSheetMode == true)
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.screen == .tournaments)
        }
    }
    
    @Suite("setActiveTournament")
    @MainActor
    struct SetActiveTournamentTests {
        
        @Test("Sets activeTournamentId in LeagueState")
        func setsActiveTournamentId() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.setActiveTournament(tournament)
            
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.activeTournamentId == tournament.id)
        }
        
        @Test("Saves context after setting active tournament")
        func savesContext() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.setActiveTournament(tournament)
            
            // Fetch fresh to verify persistence
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.activeTournamentId == tournament.id)
        }
        
        @Test("Does not change screen state - navigation handled by SwiftUI")
        func doesNotChangeScreen() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            // Set initial screen state
            let initialState = try TestHelpers.fetchLeagueState(from: context)
            let initialScreen = initialState?.screen ?? .tournaments
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.setActiveTournament(tournament)
            
            // Screen should not be changed by setActiveTournament
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.screen == initialScreen)
        }
    }
    
    @Suite("edit and delete")
    @MainActor
    struct EditDeleteTests {
        
        @Test("openEdit sets editing state")
        func openEditSetsState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament(name: "Edit Me")
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.refresh()
            viewModel.openEdit(tournament)
            
            #expect(viewModel.editingTournament?.id == tournament.id)
            #expect(viewModel.editName == "Edit Me")
            #expect(viewModel.editWeeks == tournament.totalWeeks)
            #expect(viewModel.editRandomPerWeek == tournament.randomAchievementsPerWeek)
        }
        
        @Test("saveEdit updates tournament and clears editing")
        func saveEditUpdates() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament(name: "Original")
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.refresh()
            viewModel.openEdit(tournament)
            viewModel.editName = "Updated Name"
            viewModel.editWeeks = 8
            viewModel.saveEdit()
            
            #expect(viewModel.editingTournament == nil)
            let updated = LeagueEngine.fetchTournament(context: context, id: tournament.id)
            #expect(updated?.name == "Updated Name")
            #expect(updated?.totalWeeks == 8)
        }
        
        @Test("requestDelete sets tournamentToDelete")
        func requestDeleteSetsState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.refresh()
            viewModel.requestDelete(tournament)
            
            #expect(viewModel.tournamentToDelete?.id == tournament.id)
        }
        
        @Test("confirmDelete removes tournament and refreshes")
        func confirmDeleteRemoves() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.refresh()
            #expect(viewModel.ongoingTournaments.count == 1)
            
            viewModel.requestDelete(tournament)
            viewModel.confirmDelete()
            
            #expect(viewModel.tournamentToDelete == nil)
            #expect(viewModel.ongoingTournaments.isEmpty)
            #expect(LeagueEngine.fetchTournament(context: context, id: tournament.id) == nil)
        }
        
        @Test("openCompletedStandings sets sheet state and active tournament")
        func openCompletedStandings() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            viewModel.refresh()
            viewModel.openCompletedStandings(tournament)
            
            #expect(viewModel.completedTournamentForSheet?.id == tournament.id)
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.activeTournamentId == tournament.id)
        }
        
        @Test("dismissNewTournamentSheet clears sheet state")
        func dismissNewTournamentSheet() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentsViewModel(context: context)
            viewModel.createNewTournament()
            #expect(viewModel.showNewTournamentSheet == true)
            
            viewModel.dismissNewTournamentSheet()
            
            #expect(viewModel.showNewTournamentSheet == false)
            #expect(viewModel.newTournamentSheetViewModel == nil)
        }
    }
    
    @Suite("Computed Properties")
    @MainActor
    struct ComputedPropertiesTests {
        
        @Test("hasOngoingTournaments reflects ongoing count")
        func hasOngoingTournaments() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = TournamentsViewModel(context: context)
            
            #expect(viewModel.hasOngoingTournaments == false)
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            viewModel.refresh()
            
            #expect(viewModel.hasOngoingTournaments == true)
        }
        
        @Test("hasCompletedTournaments reflects completed count")
        func hasCompletedTournaments() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = TournamentsViewModel(context: context)
            
            #expect(viewModel.hasCompletedTournaments == false)
            
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            try context.save()
            viewModel.refresh()
            
            #expect(viewModel.hasCompletedTournaments == true)
        }
        
        @Test("hasTournaments is true if either ongoing or completed exists")
        func hasTournaments() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = TournamentsViewModel(context: context)
            
            #expect(viewModel.hasTournaments == false)
            
            let tournament = TestFixtures.tournament()
            context.insert(tournament)
            try context.save()
            viewModel.refresh()
            
            #expect(viewModel.hasTournaments == true)
        }
    }
}
