import SwiftUI

/// Tournament Standings view - shows all players sorted by total points.
/// Presented as a fullScreenCover when final.
struct TournamentStandingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TournamentStandingsViewModel
    @State private var toastMessage: String?

    private var shareText: String {
        let rows = viewModel.standings.enumerated().map { index, standing in
            StandingsShareFormatter.TournamentStanding(
                rank: index + 1,
                name: viewModel.displayName(for: standing.player),
                totalPoints: standing.totalPoints,
                placementPoints: standing.placementPoints,
                achievementPoints: standing.achievementPoints,
                wins: standing.wins
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
                if viewModel.standings.isEmpty {
                    EmptyStateView(message: "No standings to display")
                } else {
                    List {
                        ForEach(Array(viewModel.standings.enumerated()), id: \.element.player.id) { index, standing in
                            StandingsRow(
                                rank: index + 1,
                                name: viewModel.displayName(for: standing.player),
                                totalPoints: standing.totalPoints,
                                placementPoints: standing.placementPoints,
                                achievementPoints: standing.achievementPoints,
                                wins: standing.wins,
                                mode: .tournament
                            )
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                ModalActionBar(
                    primaryTitle: "Close",
                    primaryAction: {
                        guard viewModel.close() else { return }
                        dismiss()
                    }
                )
            }
            .adaptiveContentWidth()
            .navigationTitle(viewModel.isFinal ? "Final Rankings" : "Tournament Rankings")
            .toolbar {
                if !viewModel.standings.isEmpty {
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
            .toastOverlay(toastMessage)
            .onPersistenceError(viewModel.persistenceErrorMessage, showToast: showToast, clearError: viewModel.clearPersistenceError)
            .onAppear {
                viewModel.refresh()
                if viewModel.isFinal {
                    AppHaptics.success()
                    if let champion = viewModel.standings.first {
                        AppAccessibility.announce(
                            "Tournament complete. \(viewModel.displayName(for: champion.player)) wins with \(champion.totalPoints) points."
                        )
                    }
                }
            }
        }
    }

    private func showToast(_ message: String) {
        ToastPresentation.show(message, binding: $toastMessage)
    }
}

#Preview {
    TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: PreviewContainer.shared.mainContext))
}
