import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Tests for PlayerDetailViewModel
@Suite("PlayerDetailViewModel Tests", .serialized)
@MainActor
struct PlayerDetailViewModelTests {
    
    @Suite("Initialization")
    @MainActor
    struct InitializationTests {
        
        @Test("Initializes with player data")
        func initializesWithPlayer() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            player.placementPoints = 50
            player.achievementPoints = 25
            player.wins = 5
            player.gamesPlayed = 15
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.player.name == "Test Player")
            #expect(viewModel.player.totalPoints == 75)
        }
    }
    
    @Suite("winRatePercentage")
    @MainActor
    struct WinRateTests {
        
        @Test("Calculates win rate correctly")
        func calculatesWinRate() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            player.wins = 5
            player.gamesPlayed = 20
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.winRatePercentage == 25.0) // 5/20 = 25%
        }
        
        @Test("Returns zero for player with no games")
        func returnsZeroWithNoGames() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.winRatePercentage == 0.0)
        }
        
        @Test("winRateString formats correctly")
        func winRateStringFormats() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            player.wins = 1
            player.gamesPlayed = 3
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.winRateString.contains("%"))
        }
    }
    
    @Suite("pointsPerGame")
    @MainActor
    struct PointsPerGameTests {
        
        @Test("Calculates points per game correctly")
        func calculatesPointsPerGame() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            player.placementPoints = 40
            player.achievementPoints = 20
            player.gamesPlayed = 10
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.pointsPerGame == 6.0) // 60/10 = 6
        }
        
        @Test("Returns zero for player with no games")
        func returnsZeroWithNoGames() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.pointsPerGame == 0.0)
        }
    }
    
    @Suite("averagePlacement")
    @MainActor
    struct AveragePlacementTests {
        
        @Test("Returns zero when no game results")
        func returnsZeroWithNoResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.averagePlacement == 0.0)
        }
        
        @Test("Calculates average from game results")
        func calculatesFromResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            context.insert(player)
            
            // Add game results: 1st, 2nd, 3rd, 4th = average 2.5
            let result1 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 1)
            let result2 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 2)
            let result3 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 3)
            let result4 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 4)
            
            context.insert(result1)
            context.insert(result2)
            context.insert(result3)
            context.insert(result4)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.averagePlacement == 2.5)
        }
        
        @Test("averagePlacementString returns N/A when no results")
        func stringReturnsNAWhenNoResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.averagePlacementString == "N/A")
        }
    }
    
    @Suite("hasGameResults")
    @MainActor
    struct HasGameResultsTests {
        
        @Test("Returns false when no game results")
        func returnsFalseWithNoResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.hasGameResults == false)
        }
        
        @Test("Returns true when game results exist")
        func returnsTrueWithResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            context.insert(player)
            
            let result = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 1)
            context.insert(result)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.hasGameResults == true)
        }
    }
    
    @Suite("placementDistribution")
    @MainActor
    struct PlacementDistributionTests {
        
        @Test("Returns distribution data from game results")
        func returnsDistribution() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            context.insert(player)
            
            // 2 first places, 1 second place
            let result1 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 1)
            let result2 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 1)
            let result3 = TestFixtures.gameResult(tournamentId: "t1", playerId: player.id, placement: 2)
            
            context.insert(result1)
            context.insert(result2)
            context.insert(result3)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            let distribution = viewModel.placementDistribution
            
            #expect(distribution.count == 4) // 1st, 2nd, 3rd, 4th
            
            let firstPlace = distribution.first(where: { $0.placement == 1 })
            #expect(firstPlace?.count == 2)
            
            let secondPlace = distribution.first(where: { $0.placement == 2 })
            #expect(secondPlace?.count == 1)
        }
    }
    
    @Suite("performanceTrend")
    @MainActor
    struct PerformanceTrendTests {
        
        @Test("Returns empty array when no game results")
        func returnsEmptyWithNoResults() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.performanceTrend.isEmpty)
        }
        
        @Test("Returns cumulative trend data")
        func returnsCumulativeTrend() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            context.insert(player)
            
            // Week 1: 4 points, Week 2: 3 points
            let result1 = GameResult(
                tournamentId: "t1",
                week: 1,
                round: 1,
                playerId: player.id,
                placement: 1,
                placementPoints: 4,
                achievementPoints: 0,
                achievementIds: [],
                podId: "pod1"
            )
            let result2 = GameResult(
                tournamentId: "t1",
                week: 2,
                round: 1,
                playerId: player.id,
                placement: 2,
                placementPoints: 3,
                achievementPoints: 0,
                achievementIds: [],
                podId: "pod2"
            )
            
            context.insert(result1)
            context.insert(result2)
            try context.save()
            
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            let trend = viewModel.performanceTrend
            
            #expect(trend.count == 2)
            
            // Week 1 cumulative: 4
            let week1 = trend.first(where: { $0.week == 1 })
            #expect(week1?.cumulativePoints == 4)
            
            // Week 2 cumulative: 4 + 3 = 7
            let week2 = trend.first(where: { $0.week == 2 })
            #expect(week2?.cumulativePoints == 7)
        }
    }
    
    @Suite("deletePlayer")
    @MainActor
    struct DeletePlayerTests {
        
        @Test("Deletes player from context")
        func deletesPlayer() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "To Delete")
            context.insert(player)
            try context.save()
            
            let playerId = player.id
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            
            let result = viewModel.deletePlayer()
            
            #expect(result == true)
            
            // Verify player is deleted
            let players = try TestHelpers.fetchAll(Player.self, from: context)
            #expect(players.first(where: { $0.id == playerId }) == nil)
        }
    }
    
    @Suite("showDeleteConfirmation")
    @MainActor
    struct DeleteConfirmationTests {
        
        @Test("confirmDelete sets showDeleteConfirmation to true")
        func confirmDeleteSetsFlag() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            context.insert(player)
            try context.save()
            
            var viewModel = PlayerDetailViewModel(context: context, player: player)
            
            #expect(viewModel.showDeleteConfirmation == false)
            
            viewModel.confirmDelete()
            
            #expect(viewModel.showDeleteConfirmation == true)
        }
    }

    @Suite("recentRounds")
    @MainActor
    struct RecentRoundsTests {

        @Test("Loads recent rounds newest first")
        func loadsRecentRounds() throws {
            let context = try TestHelpers.bootstrappedContext()

            let player = TestFixtures.player(name: "Test Player")
            let tournament = TestFixtures.tournament(name: "Spring League")
            context.insert(player)
            context.insert(tournament)

            let older = TestFixtures.gameResult(
                tournamentId: tournament.id,
                week: 1,
                round: 1,
                playerId: player.id,
                placement: 2
            )
            let newer = TestFixtures.gameResult(
                tournamentId: tournament.id,
                week: 2,
                round: 1,
                playerId: player.id,
                placement: 1
            )
            context.insert(older)
            context.insert(newer)
            try context.save()

            let viewModel = PlayerDetailViewModel(context: context, player: player)

            #expect(viewModel.recentRounds.count == 2)
            #expect(viewModel.recentRounds.first?.week == 2)
            #expect(viewModel.recentRounds.first?.tournamentName == "Spring League")
            #expect(viewModel.lastPlayedText?.contains("Last played") == true)
        }
    }

    @Suite("attendanceSummaries")
    @MainActor
    struct AttendanceSummariesTests {

        @Test("Uses attendance history when available")
        func usesAttendanceHistory() throws {
            let context = try TestHelpers.bootstrappedContext()

            let player = TestFixtures.player(name: "Test Player")
            let absentPlayer = TestFixtures.player(name: "Absent Player")
            let tournament = TestFixtures.tournament(name: "Fall League")
            tournament.attendanceHistory = [
                WeekAttendanceSnapshot(week: 1, presentPlayerIds: [player.id], confirmedAt: Date()),
                WeekAttendanceSnapshot(week: 2, presentPlayerIds: [absentPlayer.id], confirmedAt: Date())
            ]
            context.insert(player)
            context.insert(absentPlayer)
            context.insert(tournament)
            try context.save()

            let viewModel = PlayerDetailViewModel(context: context, player: player)

            #expect(viewModel.attendanceSummaries.count == 1)
            #expect(viewModel.attendanceSummaries.first?.weeksPresent == 1)
            #expect(viewModel.attendanceSummaries.first?.weeksTotal == 2)
            #expect(viewModel.overallAttendanceText?.contains("1 of 2 weeks") == true)
        }
    }

    @Suite("scoped stats")
    @MainActor
    struct ScopedStatsTests {

        @Test("Filters stats by tournament scope")
        func filtersByTournament() throws {
            let context = try TestHelpers.bootstrappedContext()

            let player = TestFixtures.player(name: "Test Player")
            let tournament = TestFixtures.tournament(name: "Scoped League")
            context.insert(player)
            context.insert(tournament)

            let result = TestFixtures.gameResult(
                tournamentId: tournament.id,
                playerId: player.id,
                placement: 1
            )
            context.insert(result)
            try context.save()

            let viewModel = PlayerDetailViewModel(context: context, player: player)
            viewModel.selectedScope = .tournament(id: tournament.id, name: tournament.name)

            #expect(viewModel.displayGamesPlayed == 1)
            #expect(viewModel.displayWins == 1)
            #expect(viewModel.scopedRecentRounds.count == 1)
        }
    }

    @Suite("formHighlightText")
    @MainActor
    struct FormHighlightTests {

        @Test("Shows active win streak")
        func showsWinStreak() throws {
            let context = try TestHelpers.bootstrappedContext()

            let player = TestFixtures.player(name: "Streak Player")
            context.insert(player)

            let win1 = TestFixtures.gameResult(tournamentId: "t1", week: 1, round: 1, playerId: player.id, placement: 1)
            let win2 = TestFixtures.gameResult(tournamentId: "t1", week: 1, round: 2, playerId: player.id, placement: 1)
            context.insert(win1)
            context.insert(win2)
            try context.save()

            let viewModel = PlayerDetailViewModel(context: context, player: player)

            #expect(viewModel.formHighlightText == "2 wins in a row")
        }
    }

    @Suite("updateName")
    @MainActor
    struct UpdateNameTests {

        @Test("Updates player name successfully")
        func updatesName() throws {
            let context = try TestHelpers.bootstrappedContext()

            let player = TestFixtures.player(name: "Old Name")
            context.insert(player)
            try context.save()

            let viewModel = PlayerDetailViewModel(context: context, player: player)
            let result = viewModel.updateName("New Name")

            if case .success = result {
                #expect(viewModel.player.name == "New Name")
            } else {
                Issue.record("Expected success")
            }
        }
    }
}
