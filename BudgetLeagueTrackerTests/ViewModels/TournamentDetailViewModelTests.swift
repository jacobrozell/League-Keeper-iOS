import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Tests for TournamentDetailViewModel
/// This replaces the deprecated PodsViewModel tests with the new tournament detail view model.
@Suite("TournamentDetailViewModel Tests", .serialized)
@MainActor
struct TournamentDetailViewModelTests {
    
    @Suite("Initialization")
    @MainActor
    struct InitializationTests {
        
        @Test("Initializes with tournament data")
        func initializesWithTournament() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.tournament != nil)
            #expect(viewModel.tournamentName == tournament.name)
        }
        
        @Test("Handles non-existent tournament gracefully")
        func handlesNonExistentTournament() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: "non-existent")
            
            #expect(viewModel.tournament == nil)
        }
    }
    
    @Suite("Tournament Properties")
    @MainActor
    struct TournamentPropertiesTests {
        
        @Test("isOngoing returns true for ongoing tournament")
        func isOngoingTrue() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.isOngoing == true)
            #expect(viewModel.isCompleted == false)
        }
        
        @Test("isCompleted returns true for completed tournament")
        func isCompletedTrue() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.isCompleted == true)
            #expect(viewModel.isOngoing == false)
        }
        
        @Test("weekProgressString formats correctly")
        func weekProgressString() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.weekProgressString.contains("Week"))
            #expect(viewModel.weekProgressString.contains("of"))
        }
        
        @Test("roundString formats correctly")
        func roundString() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.roundString.contains("Round"))
        }

        @Test("tournamentRules reflects stored tournament rules")
        func tournamentRulesReflectsStoredRules() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            var customRules = AppConstants.TournamentRulesDefaults.defaultRules
            customRules.entryFeeCents = 0
            customRules.deckBudgetCents = 10_000
            tournament.rules = customRules
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.tournamentRules == customRules)
            #expect(viewModel.tournamentRules.compactSummary().contains("Free Entry"))
            #expect(viewModel.tournamentRules.compactSummary().contains("$100 Budget"))
        }

        @Test("tournamentRules falls back to defaults when tournament missing")
        func tournamentRulesFallback() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: "missing")

            #expect(viewModel.tournamentRules == AppConstants.TournamentRulesDefaults.simpleLeagueRules)
        }
    }
    
    @Suite("hasPresentPlayers")
    @MainActor
    struct HasPresentPlayersTests {
        
        @Test("Returns true when players are present")
        func returnsTrueWithPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = ["p1", "p2", "p3"]
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.hasPresentPlayers == true)
        }
        
        @Test("Returns false when no players are present")
        func returnsFalseWithNoPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.hasPresentPlayers == false)
        }
    }
    
    @Suite("canSeatPlayers")
    @MainActor
    struct CanSeatPlayersTests {
        
        @Test("Returns true when players are present")
        func returnsTrueWithPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = ["p1", "p2", "p3", "p4"]
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.canSeatPlayers == true)
        }
        
        @Test("Returns false when no players are present")
        func returnsFalseWithNoPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.canSeatPlayers == false)
        }
    }
    
    @Suite("seatPlayers")
    @MainActor
    struct SeatPlayersTests {
        
        @Test("Generates tables from present players")
        func generatesTables() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()
            
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()
            
            #expect(!viewModel.tables.isEmpty)
            #expect(viewModel.tables[0].count == 4)
        }
        
        @Test("Does nothing when no tournament")
        func doesNothingWithNoTournament() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: "non-existent")
            viewModel.seatPlayers()
            
            #expect(viewModel.tables.isEmpty)
        }
    }
    
    @Suite("placement")
    @MainActor
    struct PlacementTests {
        
        @Test("Returns nil when no placement recorded")
        func returnsNilWithoutPlacement() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.placement(for: "unknown-player") == nil)
        }
        
        @Test("setPlacement updates tournament data")
        func setPlacementUpdates() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()
            
            let playerId = players[0].id
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            viewModel.setPlacement(for: playerId, place: 1)
            
            #expect(viewModel.placement(for: playerId) == 1)
        }
    }
    
    @Suite("achievementChecks")
    @MainActor
    struct AchievementChecksTests {
        
        @Test("isAchievementChecked returns false by default")
        func returnsFalseByDefault() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.isAchievementChecked(playerId: "p1", achievementId: "a1") == false)
        }
        
        @Test("toggleAchievementCheck toggles state")
        func togglesState() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            TestFixtures.insertSampleAchievements(into: context)
            try context.save()
            
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            let wasChecked = viewModel.isAchievementChecked(playerId: "p1", achievementId: "a1")
            viewModel.toggleAchievementCheck(playerId: "p1", achievementId: "a1")
            
            #expect(viewModel.isAchievementChecked(playerId: "p1", achievementId: "a1") != wasChecked)
        }
    }
    
    @Suite("canEdit")
    @MainActor
    struct CanEditTests {
        
        @Test("Returns false when no history")
        func returnsFalseWithNoHistory() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.podHistorySnapshots = []
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.canEdit == false)
        }

        @Test("Lists editable rounds from the current week only")
        func editableRoundsThisWeek() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.currentWeek = 2
            tournament.podHistorySnapshots = [
                PodSnapshot(week: 1, round: 3, playerIds: ["p1"], placements: ["p1": 1], achievementChecks: [], playerDeltas: [:], weeklyDeltas: [:]),
                PodSnapshot(week: 2, round: 1, playerIds: ["p1", "p2"], placements: ["p1": 1, "p2": 2], achievementChecks: [], playerDeltas: [:], weeklyDeltas: [:])
            ]
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.editableRoundsThisWeek.count == 1)
            #expect(viewModel.editableRoundsThisWeek.first?.round == 1)
            #expect(viewModel.canEdit == true)
        }
    }

    @Suite("Manual seating")
    @MainActor
    struct ManualSeatingTests {

        @Test("Surfaces warning when stored seatings reference missing players")
        func tableLoadIssueWhenPlayerMissing() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            let players = TestFixtures.players("A", "B", "C", "D", "E", "F", "G")
            players.forEach { context.insert($0) }
            tournament.presentPlayerIds = players.map(\.id)
            tournament.currentRoundPodsPlayerIds = [
                players.prefix(4).map(\.id),
                ["missing-player"] + players.suffix(3).map(\.id)
            ]
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.tableLoadIssueMessage != nil)
            #expect(viewModel.tables.count == 1)
        }

        @Test("Moves player between tables before scoring")
        func movesPlayerBetweenTables() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            let players = TestFixtures.players("A", "B", "C", "D", "E", "F", "G", "H")
            players.forEach { context.insert($0) }
            tournament.presentPlayerIds = players.map(\.id)
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()
            #expect(viewModel.tables.count == 2)
            #expect(viewModel.tables[0].count == 4)

            let movingPlayer = viewModel.tables[0][0]
            viewModel.movePlayer(movingPlayer.id, fromTable: 0, toTable: 1)

            #expect(viewModel.tables[0].count == 3)
            #expect(viewModel.tables[1].contains { $0.id == movingPlayer.id })
            #expect(viewModel.canEditSeatings == true)
        }
    }

    @Suite("canNextRound")
    @MainActor
    struct CanNextRoundTests {

        @Test("Returns false when attendance is not confirmed")
        func returnsFalseWithoutAttendance() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.canNextRound == false)
        }

        @Test("Returns false when pods are not generated")
        func returnsFalseWithoutPods() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.canNextRound == false)
        }

        @Test("Returns true after every table is confirmed")
        func returnsTrueAfterAllTablesConfirmed() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()
            viewModel.startScoring()
            viewModel.confirmAllTables()

            #expect(viewModel.canNextRound == true)
        }

        @Test("Returns false after seating before tables are confirmed")
        func returnsFalseAfterSeatingOnly() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()

            #expect(viewModel.canNextRound == false)
        }
    }

    @Suite("nextRoundButtonTitle")
    @MainActor
    struct NextRoundButtonTitleTests {

        @Test("Uses finish round wording before final round of week")
        func finishRoundTitle() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.currentRound = 1
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.nextRoundButtonTitle == "Finish Round 1")
        }

        @Test("Uses end week wording on final round of non-final week")
        func endWeekTitle() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.currentRound = AppConstants.League.roundsPerWeek
            tournament.currentWeek = 1
            tournament.totalWeeks = 6
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.nextRoundButtonTitle == "End Week & Show Standings")
        }

        @Test("Uses end tournament wording on final week")
        func endTournamentTitle() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.currentRound = AppConstants.League.roundsPerWeek
            tournament.currentWeek = tournament.totalWeeks
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.nextRoundButtonTitle == "End Tournament")
        }
    }

    @Suite("syncActiveTab")
    @MainActor
    struct SyncActiveTabTests {

        @Test("Defaults to attendance when no players are present")
        func defaultsToAttendance() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.activeTab == .attendance)
        }

        @Test("Defaults to pods when attendance is confirmed")
        func defaultsToPods() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.activeTab == .round)
        }
    }

    @Suite("hostStep")
    @MainActor
    struct HostStepTests {

        @Test("Starts at attendance when no players are present")
        func attendanceStep() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.hostStep == .attendance)
            #expect(viewModel.nextStepHint == "Mark who's here this week")
        }

        @Test("Moves to pods after attendance is confirmed")
        func podsStep() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.hostStep == .seatPlayers)
            #expect(viewModel.nextStepHint.contains("Seat players"))
        }

        @Test("Moves to score round after pods are generated")
        func scoreStep() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()

            #expect(viewModel.hostStep == .scoreRound)
            #expect(viewModel.nextStepHint.contains("Review tables"))
        }

        @Test("Marks seat complete and score current after seating")
        func progressStepsAfterSeating() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()

            let steps = viewModel.progressSteps
            #expect(steps.first { $0.id == "seat" }?.state == .complete)
            #expect(steps.first { $0.id == "score" }?.state == .current)
        }
    }

    @Suite("seatPlayersButtonTitle")
    @MainActor
    struct SeatPlayersButtonTitleTests {

        @Test("Uses seat players wording")
        func seatPlayersTitle() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.currentRound = 2
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.seatPlayersButtonTitle == "Seat Players")
        }
    }

    @Suite("nextRound week complete")
    @MainActor
    struct NextRoundWeekCompleteTests {

        @Test("Shows week complete sheet when ending a non-final week")
        func showsWeekCompleteSheet() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            tournament.currentRound = AppConstants.League.roundsPerWeek
            tournament.currentWeek = 1
            tournament.totalWeeks = 6
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()
            viewModel.startScoring()
            viewModel.confirmAllTables()
            viewModel.nextRound()

            #expect(viewModel.showWeekCompleteSheet == true)
            #expect(viewModel.completedWeekNumber == 1)
            #expect(viewModel.currentWeek == 2)
        }
    }

    @Suite("standingsWeekPickerLabel")
    @MainActor
    struct StandingsWeekPickerLabelTests {
        @Test("Describes tournament overall when no week selected")
        func overall() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.standingsWeekPickerLabel == "Tournament overall")
        }

        @Test("Describes selected week")
        func week() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.selectedStandingsWeek = 2

            #expect(viewModel.standingsWeekPickerLabel == "Week 2")
        }
    }

    @Suite("roundPhase")
    @MainActor
    struct RoundPhaseTests {

        @Test("Starts in seating before tables exist")
        func seatingPhase() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)

            #expect(viewModel.roundPhase == .seating)
        }

        @Test("Moves to seatings ready after seating players")
        func seatingsReadyPhase() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()

            #expect(viewModel.roundPhase == .seatingsReady)
        }

        @Test("Moves to review after all tables are confirmed")
        func reviewPhase() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()

            var viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.seatPlayers()
            viewModel.startScoring()
            viewModel.confirmAllTables()

            #expect(viewModel.roundPhase == .review)
        }
    }
    
    @Suite("weeklyStandings")
    @MainActor
    struct WeeklyStandingsTests {
        
        @Test("Returns empty when no present players")
        func returnsEmptyWithNoPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = []
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.weeklyStandings.isEmpty)
        }
        
        @Test("Returns standings for present players")
        func returnsStandingsForPresentPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let players = TestFixtures.insertStandardPlayers(into: context)
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            tournament.presentPlayerIds = players.map { $0.id }
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.weeklyStandings.count == players.count)
        }
    }
    
    @Suite("finalStandings")
    @MainActor
    struct FinalStandingsTests {
        
        @Test("Returns empty for ongoing tournament")
        func returnsEmptyForOngoing() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.finalStandings.isEmpty)
        }
        
        @Test("Returns standings for completed tournament with results")
        func returnsStandingsForCompleted() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player1 = TestFixtures.player(name: "Winner")
            let player2 = TestFixtures.player(name: "Loser")
            context.insert(player1)
            context.insert(player2)
            
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            
            // Add game results
            let result1 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: player1.id, placement: 1)
            let result2 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: player2.id, placement: 4)
            context.insert(result1)
            context.insert(result2)
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.finalStandings.count == 2)
            #expect(viewModel.finalStandings[0].player.name == "Winner") // Higher points first
        }
    }
    
    @Suite("winnerName")
    @MainActor
    struct WinnerNameTests {
        
        @Test("Returns winner name for completed tournament")
        func returnsWinnerName() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player1 = TestFixtures.player(name: "Champion")
            let player2 = TestFixtures.player(name: "Runner Up")
            context.insert(player1)
            context.insert(player2)
            
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            
            let result1 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: player1.id, placement: 1)
            let result2 = TestFixtures.gameResult(tournamentId: tournament.id, playerId: player2.id, placement: 4)
            context.insert(result1)
            context.insert(result2)
            try context.save()
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.winnerName == "Champion")
        }
        
        @Test("Returns nil for ongoing tournament")
        func returnsNilForOngoing() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            
            #expect(viewModel.winnerName == nil)
        }
    }
    
    @Suite("setAsActiveTournament")
    @MainActor
    struct SetAsActiveTournamentTests {
        
        @Test("Sets activeTournamentId in LeagueState")
        func setsActiveTournamentId() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            // Create a different tournament
            let otherTournament = TestFixtures.tournament(name: "Other")
            context.insert(otherTournament)
            try context.save()
            
            var viewModel = TournamentDetailViewModel(context: context, tournamentId: otherTournament.id)
            viewModel.setAsActiveTournament()
            
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.activeTournamentId == otherTournament.id)
        }
    }
    
    @Suite("goToAttendance")
    @MainActor
    struct GoToAttendanceTests {
        
        @Test("Sets active tournament and switches to attendance tab")
        func setsActiveTournamentAndSwitchesToAttendanceTab() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            #expect(viewModel.activeTab != .attendance)
            
            viewModel.goToAttendance()
            
            let state = try TestHelpers.fetchLeagueState(from: context)
            #expect(state?.activeTournamentId == tournament.id)
            #expect(viewModel.activeTab == .attendance)
        }
    }
}
