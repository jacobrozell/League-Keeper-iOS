import Testing
import SwiftUI
import SwiftData
import SnapshotTesting
@testable import BudgetLeagueTracker

@Suite("Round Flow Snapshot Tests", .serialized)
@MainActor
struct RoundFlowSnapshotTests {

    @Suite("RoundSeatingView")
    @MainActor
    struct RoundSeatingViewSnapshots {
        @Test("Seating empty state")
        func seatingEmptyState() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try #require(try TestHelpers.fetchActiveTournament(from: context))
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.refresh()

            let view = RoundSeatingView(
                viewModel: viewModel,
                usesSidebarLayout: false,
                horizontalSizeClass: .compact,
                includeSidebarSections: true,
                onMovePlayerFeedback: { _ in }
            )
            .frame(width: 390, height: 700)

            assertSnapshot(
                of: view,
                as: .image(precision: 0.98, layout: .fixed(width: 390, height: 700)),
                named: "RoundSeatingView_emptyState",
                record: SnapshotTestConfiguration.record
            )
        }

        @Test("Seatings ready with tables")
        func seatingsReady() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try #require(try TestHelpers.fetchActiveTournament(from: context))
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.refresh()
            viewModel.seatPlayers()

            let view = RoundSeatingView(
                viewModel: viewModel,
                usesSidebarLayout: false,
                horizontalSizeClass: .compact,
                includeSidebarSections: true,
                onMovePlayerFeedback: { _ in }
            )
            .frame(width: 390, height: 700)

            assertSnapshot(
                of: view,
                as: .image(precision: 0.98, layout: .fixed(width: 390, height: 700)),
                named: "RoundSeatingView_seatingsReady",
                record: SnapshotTestConfiguration.record
            )
        }
    }

    @Suite("RoundScoringView")
    @MainActor
    struct RoundScoringViewSnapshots {
        @Test("Scoring table")
        func scoringTable() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try #require(try TestHelpers.fetchActiveTournament(from: context))
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.refresh()
            viewModel.seatPlayers()
            viewModel.startScoring()

            let view = RoundScoringView(
                viewModel: viewModel,
                usesSidebarLayout: false,
                includeBonusesInList: true
            )
            .frame(width: 390, height: 700)

            assertSnapshot(
                of: view,
                as: .image(precision: 0.98, layout: .fixed(width: 390, height: 700)),
                named: "RoundScoringView_scoringTable",
                record: SnapshotTestConfiguration.record
            )
        }
    }

    @Suite("RoundReviewView")
    @MainActor
    struct RoundReviewViewSnapshots {
        @Test("Review after all tables scored")
        func reviewState() throws {
            let context = try TestHelpers.contextWithTournament()
            let tournament = try #require(try TestHelpers.fetchActiveTournament(from: context))
            let viewModel = TournamentDetailViewModel(context: context, tournamentId: tournament.id)
            viewModel.refresh()
            viewModel.seatPlayers()
            viewModel.startScoring()
            for index in viewModel.tables.indices {
                viewModel.selectScoringTable(index)
                viewModel.confirmTable(at: index)
            }

            let view = RoundReviewView(
                viewModel: viewModel,
                usesSidebarLayout: false,
                horizontalSizeClass: .compact,
                includeSidebarSections: true
            )
            .frame(width: 390, height: 700)

            assertSnapshot(
                of: view,
                as: .image(precision: 0.98, layout: .fixed(width: 390, height: 700)),
                named: "RoundReviewView_reviewState",
                record: SnapshotTestConfiguration.record
            )
        }
    }
}
