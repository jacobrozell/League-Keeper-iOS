import Testing
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import BudgetLeagueTracker

/// Snapshot tests for screen-level visual regression
/// Note: Set `SnapshotTestConfiguration.record = true` to generate reference snapshots
@Suite("Screen Snapshot Tests", .serialized)
@MainActor
struct ScreenSnapshotTests {
    
    // MARK: - TournamentsView Snapshots
    
    @Suite("TournamentsView")
    @MainActor
    struct TournamentsViewSnapshots {
        
        @Test("Empty state")
        func emptyState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentsViewModel(context: context)
            let view = TournamentsView(viewModel: viewModel, navigationPath: .constant([]))
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
        
        @Test("With tournaments")
        func withTournaments() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let ongoing = TestFixtures.tournament(name: "Spring League")
            ongoing.currentWeek = 3
            context.insert(ongoing)
            
            let completed = TestFixtures.completedTournament()
            context.insert(completed)
            try context.save()
            
            let viewModel = TournamentsViewModel(context: context)
            let view = TournamentsView(viewModel: viewModel, navigationPath: .constant([]))
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }

        @Test("Empty state (landscape)")
        func emptyStateLandscape() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = TournamentsViewModel(context: context)
            let view = TournamentsView(viewModel: viewModel, navigationPath: .constant([]))
                .frame(width: 844, height: 390)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 844, height: 390)), named: "emptyState_landscape", record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - StatsView Snapshots
    
    @Suite("StatsView")
    @MainActor
    struct StatsViewSnapshots {
        @Test("Empty state")
        func emptyState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = StatsViewModel(context: context)
            let view = StatsView(viewModel: viewModel)
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
        
        @Test("With stats")
        func withStats() throws {
            let context = try TestHelpers.bootstrappedContext()
            
            let players = [
                TestFixtures.player(name: "Alice", placementPoints: 45, achievementPoints: 12, wins: 8, gamesPlayed: 15),
                TestFixtures.player(name: "Bob", placementPoints: 38, achievementPoints: 8, wins: 6, gamesPlayed: 15),
                TestFixtures.player(name: "Charlie", placementPoints: 30, achievementPoints: 10, wins: 4, gamesPlayed: 15)
            ]
            
            for player in players {
                context.insert(player)
            }
            try context.save()
            
            let viewModel = StatsViewModel(context: context)
            let view = StatsView(viewModel: viewModel)
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - AchievementsView Snapshots
    
    @Suite("AchievementsView")
    @MainActor
    struct AchievementsViewSnapshots {
        @Test("Empty state")
        func emptyState() throws {
            let context = try TestHelpers.cleanContext()
            
            // Bootstrap state without default achievement
            let state = LeagueState()
            context.insert(state)
            try context.save()
            
            let viewModel = AchievementsViewModel(context: context)
            let view = AchievementsView(viewModel: viewModel)
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
        
        @Test("With achievements")
        func withAchievements() throws {
            let context = try TestHelpers.bootstrappedContext()
            TestFixtures.insertSampleAchievements(into: context)
            try context.save()
            
            let viewModel = AchievementsViewModel(context: context)
            let view = AchievementsView(viewModel: viewModel)
                .frame(width: 390, height: 844)
            
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - DashboardView Snapshots
    
    @Suite("DashboardView")
    @MainActor
    struct DashboardViewSnapshots {
        @Test("Default state")
        func defaultState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = DashboardViewModel(context: context)
            let view = DashboardView(viewModel: viewModel)
                .frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - PlayersView Snapshots
    
    @Suite("PlayersView")
    @MainActor
    struct PlayersViewSnapshots {
        @Test("Empty state")
        func emptyState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = PlayersViewModel(context: context)
            let view = PlayersView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
        
        @Test("With players")
        func withPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            for name in ["Alice", "Bob", "Charlie"] {
                context.insert(TestFixtures.player(name: name))
            }
            try context.save()
            let viewModel = PlayersViewModel(context: context)
            let view = PlayersView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - SettingsView Snapshots
    
    @Suite("SettingsView")
    @MainActor
    struct SettingsViewSnapshots {
        @Test("Default")
        func `default`() {
            let view = SettingsView().frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }

        @Test("Default (dark mode)")
        func defaultDark() {
            let view = SettingsView().frame(width: 390, height: 844).darkModeForSnapshot()
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), named: "default_dark", record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - NewTournamentView Snapshots
    
    @Suite("NewTournamentView")
    @MainActor
    struct NewTournamentViewSnapshots {
        @Test("Empty form")
        func emptyForm() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = NewTournamentViewModel(context: context)
            let view = NewTournamentView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - AddPlayersView Snapshots
    
    @Suite("AddPlayersView")
    @MainActor
    struct AddPlayersViewSnapshots {
        @Test("Empty state")
        func emptyState() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = AddPlayersViewModel(context: context)
            let view = AddPlayersView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
        
        @Test("With players")
        func withPlayers() throws {
            let context = try TestHelpers.bootstrappedContext()
            for name in ["Alice", "Bob", "Charlie", "Diana"] {
                context.insert(TestFixtures.player(name: name))
            }
            try context.save()
            let viewModel = AddPlayersViewModel(context: context)
            let view = AddPlayersView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - PodsView Snapshots
    
    @Suite("PodsView")
    @MainActor
    struct PodsViewSnapshots {
        @Test("With pods context")
        func withPodsContext() throws {
            let context = try TestHelpers.contextWithTournament()
            let viewModel = PodsViewModel(context: context)
            let view = PodsView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - TournamentDetailView Snapshots
    
    @Suite("TournamentDetailView")
    @MainActor
    struct TournamentDetailViewSnapshots {
        @Test("Ongoing tournament")
        func ongoingTournament() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            let view = TournamentDetailView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - AttendanceView Snapshots
    
    @Suite("AttendanceView")
    @MainActor
    struct AttendanceViewSnapshots {
        @Test("With players")
        func withPlayers() throws {
            let context = try TestHelpers.contextWithTournament()
            let viewModel = AttendanceViewModel(context: context)
            let view = AttendanceView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - ConfirmNewTournamentView Snapshots
    
    @Suite("ConfirmNewTournamentView")
    @MainActor
    struct ConfirmNewTournamentViewSnapshots {
        @Test("Default")
        func `default`() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = ConfirmNewTournamentViewModel(context: context)
            let view = ConfirmNewTournamentView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - TournamentStandingsView Snapshots
    
    @Suite("TournamentStandingsView")
    @MainActor
    struct TournamentStandingsViewSnapshots {
        @Test("With completed tournament")
        func withCompletedTournament() throws {
            let context = try TestHelpers.bootstrappedContext()
            _ = TestFixtures.insertStandardPlayers(into: context)
            let tournament = TestFixtures.completedTournament()
            context.insert(tournament)
            if let state = try TestHelpers.fetchLeagueState(from: context) {
                state.activeTournamentId = tournament.id
                state.currentScreen = Screen.tournamentStandings.rawValue
            }
            try context.save()
            let viewModel = TournamentStandingsViewModel(context: context)
            let view = TournamentStandingsView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - PlayerDetailView Snapshots
    
    @Suite("PlayerDetailView")
    @MainActor
    struct PlayerDetailViewSnapshots {
        @Test("With player")
        func withPlayer() throws {
            let context = try TestHelpers.bootstrappedContext()
            let player = TestFixtures.player(name: "Alice", placementPoints: 20, achievementPoints: 8, wins: 3, gamesPlayed: 10)
            context.insert(player)
            try context.save()
            let viewModel = PlayerDetailViewModel(context: context, player: player)
            let view = PlayerDetailView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - EditLastRoundView Snapshots
    
    @Suite("EditLastRoundView")
    @MainActor
    struct EditLastRoundViewSnapshots {
        @Test("With tournament context")
        func withTournamentContext() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try TestHelpers.fetchActiveTournament(from: context)!
            let viewModel = EditLastRoundViewModel(context: context, tournamentId: tournament.id)
            let view = EditLastRoundView(viewModel: viewModel, onSave: {}).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - NewAchievementView Snapshots
    
    @Suite("NewAchievementView")
    @MainActor
    struct NewAchievementViewSnapshots {
        @Test("Empty form")
        func emptyForm() throws {
            let context = try TestHelpers.bootstrappedContext()
            let viewModel = NewAchievementViewModel(context: context)
            let view = NewAchievementView(viewModel: viewModel).frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
    
    // MARK: - EditTournamentView Snapshots
    
    @Suite("EditTournamentView")
    @MainActor
    struct EditTournamentViewSnapshots {
        @Test("With tournament")
        func withTournament() throws {
            let context = try TestHelpers.bootstrappedContext()
            let tournament = TestFixtures.tournament(name: "Spring League")
            context.insert(tournament)
            try context.save()
            let viewModel = TournamentsViewModel(context: context)
            let view = EditTournamentView(viewModel: viewModel, tournament: tournament)
                .frame(width: 390, height: 844)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 390, height: 844)), record: SnapshotTestConfiguration.record)
        }
    }
}
