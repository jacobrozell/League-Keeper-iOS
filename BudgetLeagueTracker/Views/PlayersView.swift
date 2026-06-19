import SwiftUI

/// Players view - displays all players with navigation to detail views.
/// Allows viewing player stats and managing the player roster.
struct PlayersView: View {
    @Bindable var viewModel: PlayersViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var toastMessage: String?

    var body: some View {
        Group {
            if viewModel.hasPlayers {
                playersList
            } else {
                emptyState
            }
        }
        .navigationTitle("Players")
        .searchable(text: $viewModel.searchText, prompt: "Search players")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort by", selection: Binding(
                        get: { viewModel.sortOption },
                        set: { viewModel.updateSortOption($0) }
                    )) {
                        ForEach(PlayerSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
                .accessibilityLabel("Sort players")
            }
        }
        .adaptiveContentWidth()
        .overlay(alignment: .bottomTrailing) {
            if viewModel.hasPlayers {
                addPlayerFAB
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddPlayerSheet, onDismiss: {
            if let message = viewModel.consumePendingToast() {
                ToastPresentation.show(message, binding: $toastMessage)
            }
        }) {
            AddPlayerSheet(viewModel: viewModel)
        }
        .toastOverlay(toastMessage)
        .onAppear {
            viewModel.refresh()
        }
    }

    // MARK: - Players List

    @ViewBuilder
    private var playersList: some View {
        List {
            if viewModel.filteredPlayers.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "person.slash")
                } description: {
                    Text("No players match “\(viewModel.searchText)”")
                }
                .brandedInsetListRow()
            } else {
                Section("All Players") {
                    ForEach(viewModel.filteredPlayers, id: \.id) { player in
                        NavigationLink(value: player) {
                            PlayerRow(
                                name: viewModel.displayName(for: player),
                                mode: .display(
                                    subtitle: viewModel.subtitle(for: player),
                                    showAvatar: true,
                                    playerId: player.id,
                                    rank: viewModel.rank(for: player),
                                    recentPlacements: viewModel.recentPlacements(for: player),
                                    sparklinePoints: viewModel.sparklinePoints(for: player)
                                )
                            )
                        }
                        .brandedInsetListRow()
                    }
                }
            }
        }
        .brandedListChrome()
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            EmptyStateView(
                message: "No players yet",
                hint: "Add players to track their stats across tournaments.",
                systemImage: "person.crop.rectangle.stack"
            )

            Spacer()

            PrimaryActionButton(title: "Add Player") {
                viewModel.isShowingAddPlayerSheet = true
            }
            .accessibilityIdentifier("Add Player")
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .adaptiveEmptyStateLayout()
    }

    // MARK: - FAB

    @ViewBuilder
    private var addPlayerFAB: some View {
        FloatingActionButton(
            systemImage: "plus",
            accessibilityLabel: "Add player",
            accessibilityIdentifier: "addPlayerFAB"
        ) {
            viewModel.isShowingAddPlayerSheet = true
        }
        .padding(.trailing, 20)
        .padding(.bottom, fabClearance)
    }

    private var fabClearance: CGFloat {
        AdaptiveLayout.tabBarClearance(for: dynamicTypeSize)
    }
}

#Preview {
    NavigationStack {
        PlayersView(viewModel: PlayersViewModel(context: PreviewContainer.shared.mainContext))
    }
}
