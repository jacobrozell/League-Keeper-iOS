import Testing
import SwiftData
import Foundation
@testable import BudgetLeagueTracker

/// Tests for PlayersViewModel
@Suite("PlayersViewModel Tests", .serialized)
@MainActor
struct PlayersViewModelTests {
    
    @Suite("refresh")
    @MainActor
    struct RefreshTests {
        
        @Test("Loads all players from context")
        func loadsPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            TestFixtures.insertStandardPlayers(into: context)
            try context.save()
            
            let viewModel = PlayersViewModel(context: context)
            
            #expect(viewModel.players.count == 4)
        }
        
        @Test("Players are sorted by name by default fetch order")
        func playersSortedByName() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let charlie = TestFixtures.player(name: "Charlie")
            let alice = TestFixtures.player(name: "Alice")
            let bob = TestFixtures.player(name: "Bob")
            
            context.insert(charlie)
            context.insert(alice)
            context.insert(bob)
            try context.save()
            
            let viewModel = PlayersViewModel(context: context)
            
            #expect(viewModel.players[0].name == "Alice")
            #expect(viewModel.players[1].name == "Bob")
            #expect(viewModel.players[2].name == "Charlie")
        }
        
        @Test("Empty players list when no players exist")
        func emptyWhenNoPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let viewModel = PlayersViewModel(context: context)
            
            #expect(viewModel.players.isEmpty)
        }
    }
    
    @Suite("hasPlayers")
    @MainActor
    struct HasPlayersTests {
        
        @Test("Returns true when players exist")
        func returnsTrueWithPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            TestFixtures.insertStandardPlayers(into: context)
            try context.save()
            
            let viewModel = PlayersViewModel(context: context)
            
            #expect(viewModel.hasPlayers == true)
        }
        
        @Test("Returns false when no players exist")
        func returnsFalseWithoutPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let viewModel = PlayersViewModel(context: context)
            
            #expect(viewModel.hasPlayers == false)
        }
    }
    
    @Suite("canAddPlayer")
    @MainActor
    struct CanAddPlayerTests {
        
        @Test("Returns true when name is not empty")
        func returnsTrueWithName() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = "New Player"
            
            #expect(viewModel.canAddPlayer == true)
        }
        
        @Test("Returns false when name is empty")
        func returnsFalseWithEmptyName() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = ""
            
            #expect(viewModel.canAddPlayer == false)
        }
        
        @Test("Returns false when name is only whitespace")
        func returnsFalseWithWhitespace() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = "   "
            
            #expect(viewModel.canAddPlayer == false)
        }
    }
    
    @Suite("addPlayer")
    @MainActor
    struct AddPlayerTests {
        
        @Test("Creates new player and clears input")
        func createsPlayerAndClearsInput() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = "New Player"
            let result = viewModel.addPlayer()
            
            if case .added(let player) = result {
                #expect(player.name == "New Player")
            } else {
                Issue.record("Expected added player")
            }
            #expect(viewModel.newPlayerName == "")
            #expect(viewModel.players.count == 1)
        }
        
        @Test("Does not create player with empty name")
        func doesNotCreateWithEmptyName() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = ""
            let result = viewModel.addPlayer()
            
            if case .validationError = result {
                #expect(Bool(true))
            } else {
                Issue.record("Expected validation error")
            }
            #expect(viewModel.players.isEmpty)
        }
        
        @Test("Does not create player with whitespace-only name")
        func doesNotCreateWithWhitespace() throws {
            let context = try TestHelpers.bootstrappedContext()
            var viewModel = PlayersViewModel(context: context)
            
            viewModel.newPlayerName = "   "
            let result = viewModel.addPlayer()
            
            if case .validationError = result {
                #expect(Bool(true))
            } else {
                Issue.record("Expected validation error")
            }
            #expect(viewModel.players.isEmpty)
        }

        @Test("Allows duplicate player name")
        func allowsDuplicateName() throws {
            let context = try TestHelpers.bootstrappedContext()
            let existing = Player(id: "player-a", name: "Alex")
            context.insert(existing)
            try context.save()

            var viewModel = PlayersViewModel(context: context)
            viewModel.newPlayerName = "alex"
            let result = viewModel.addPlayer()

            if case .added = result {
                #expect(viewModel.players.count == 2)
                let labels = viewModel.players.map { viewModel.displayName(for: $0) }
                #expect(Set(labels).count == 2)
                #expect(labels.allSatisfy { $0.contains("(") })
            } else {
                Issue.record("Expected player to be added")
            }
        }

        @Test("Shows duplicate name hint without nickname")
        func showsDuplicateHint() throws {
            let context = try TestHelpers.bootstrappedContext()
            context.insert(TestFixtures.player(name: "Devan"))
            try context.save()

            var viewModel = PlayersViewModel(context: context)
            viewModel.newPlayerName = "Devan"

            #expect(viewModel.duplicateNameHint?.contains("nickname") == true)
            viewModel.newPlayerNote = "Smith"
            #expect(viewModel.duplicateNameHint == nil)
        }
    }
    
    @Suite("subtitle")
    @MainActor
    struct SubtitleTests {
        
        @Test("Returns formatted subtitle with stats")
        func returnsFormattedSubtitle() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "Test Player")
            player.placementPoints = 50
            player.achievementPoints = 25
            player.gamesPlayed = 15
            player.wins = 5
            context.insert(player)
            try context.save()
            
            let viewModel = PlayersViewModel(context: context)
            let subtitle = viewModel.subtitle(for: player)
            
            #expect(subtitle.contains("75 pts"))
            #expect(subtitle.contains("15 games"))
            #expect(subtitle.contains("5 wins"))
        }
        
        @Test("Handles zero stats gracefully")
        func handlesZeroStats() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let player = TestFixtures.player(name: "New Player")
            context.insert(player)
            try context.save()
            
            let viewModel = PlayersViewModel(context: context)
            let subtitle = viewModel.subtitle(for: player)
            
            #expect(subtitle.contains("0 pts"))
            #expect(subtitle.contains("0 games"))
            #expect(subtitle.contains("0 wins"))
        }
    }

    @Suite("search and sort")
    @MainActor
    struct SearchAndSortTests {

        @Test("Filters players by search text")
        func filtersBySearch() throws {
            let context = try TestHelpers.bootstrappedContext()
            TestFixtures.insertStandardPlayers(into: context)
            try context.save()

            var viewModel = PlayersViewModel(context: context)
            viewModel.searchText = "alice"

            #expect(viewModel.filteredPlayers.count == 1)
            #expect(viewModel.filteredPlayers.first?.name == "Alice")
        }

        @Test("Sorts players by points")
        func sortsByPoints() throws {
            let context = try TestHelpers.bootstrappedContext()

            let low = TestFixtures.player(name: "Low")
            low.placementPoints = 5
            let high = TestFixtures.player(name: "High")
            high.placementPoints = 50
            context.insert(low)
            context.insert(high)
            try context.save()

            var viewModel = PlayersViewModel(context: context)
            viewModel.sortOption = .points

            #expect(viewModel.filteredPlayers.first?.name == "High")
        }

        @Test("Returns league rank by points")
        func returnsRank() throws {
            let context = try TestHelpers.bootstrappedContext()

            let first = TestFixtures.player(name: "First")
            first.placementPoints = 100
            let second = TestFixtures.player(name: "Second")
            second.placementPoints = 10
            context.insert(first)
            context.insert(second)
            try context.save()

            let viewModel = PlayersViewModel(context: context)

            #expect(viewModel.rank(for: first) == 1)
            #expect(viewModel.rank(for: second) == 2)
        }
    }
}
