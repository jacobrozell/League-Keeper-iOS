import SwiftUI

/// Tournament Standings view - shows all players sorted by total points.
/// Presented as a fullScreenCover when final.
struct TournamentStandingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TournamentStandingsViewModel

    private var shareText: String {
        let rows = viewModel.sortedPlayers.enumerated().map { index, player in
            StandingsShareFormatter.TournamentStanding(
                rank: index + 1,
                name: viewModel.displayName(for: player),
                totalPoints: player.totalPoints,
                placementPoints: player.placementPoints,
                achievementPoints: player.achievementPoints,
                wins: player.wins
            )
        }
        return StandingsShareFormatter.finalStandings(
            tournamentName: viewModel.tournamentName,
            standings: rows
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.sortedPlayers.isEmpty {
                    EmptyStateView(message: "No standings to display")
                } else {
                    List {
                        ForEach(Array(viewModel.sortedPlayers.enumerated()), id: \.element.id) { index, player in
                            StandingsRow(
                                rank: index + 1,
                                name: viewModel.displayName(for: player),
                                totalPoints: player.totalPoints,
                                placementPoints: player.placementPoints,
                                achievementPoints: player.achievementPoints,
                                wins: player.wins,
                                mode: .tournament
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                ModalActionBar(
                    primaryTitle: "Close",
                    primaryAction: {
                        viewModel.close()
                        dismiss()
                    }
                )
            }
            .adaptiveContentWidth()
            .navigationTitle(viewModel.isFinal ? "Final Rankings" : "Tournament Rankings")
            .toolbar {
                if !viewModel.sortedPlayers.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(
                            item: shareText,
                            subject: Text("\(viewModel.tournamentName) — Final standings"),
                            message: Text(shareText)
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share final tournament standings")
                        .accessibilityIdentifier("shareFinalStandings")
                    }
                }
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }
}

#Preview {
    TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: PreviewContainer.shared.mainContext))
}
