import SwiftUI

/// Players view - displays all players with navigation to detail views.
/// Allows viewing player stats and managing the player roster.
struct PlayersView: View {
    @Bindable var viewModel: PlayersViewModel
    
    var body: some View {
        Group {
            if viewModel.hasPlayers {
                playersList
            } else {
                emptyState
            }
        }
        .navigationTitle("Players")
        .brandedScreenBackground()
        .adaptiveContentWidth()
        .onAppear {
            viewModel.refresh()
        }
    }
    
    // MARK: - Players List
    
    @ViewBuilder
    private var playersList: some View {
        List {
            // Add player section at top
            Section {
                addPlayerRow
            }
            
            // Players section
            Section("All Players") {
                ForEach(viewModel.players, id: \.id) { player in
                    NavigationLink(value: player) {
                        PlayerRow(
                            name: player.name,
                            mode: .display(subtitle: viewModel.subtitle(for: player))
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
            
            // Add player inline
            VStack(spacing: 12) {
                HStack {
                    TextField("Player name", text: $viewModel.newPlayerName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .submitLabel(.done)
                        .accessibilityLabel("Player name")
                        .accessibilityIdentifier("playerNameField")
                        .onSubmit {
                            viewModel.addPlayer()
                        }

                    Button("Add") {
                        viewModel.addPlayer()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canAddPlayer)
                    .accessibilityLabel("Add player")
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .adaptiveEmptyStateLayout()
    }
    
    // MARK: - Add Player Row
    
    @ViewBuilder
    private var addPlayerRow: some View {
        HStack {
            TextField("Add new player", text: $viewModel.newPlayerName)
                .textContentType(.name)
                .submitLabel(.done)
                .accessibilityLabel("Add new player")
                .accessibilityIdentifier("addNewPlayerField")
                .onSubmit {
                    viewModel.addPlayer()
                }

            Button("Add") {
                viewModel.addPlayer()
            }
            .disabled(!viewModel.canAddPlayer)
            .accessibilityLabel("Add player")
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
    }
}

#Preview {
    NavigationStack {
        PlayersView(viewModel: PlayersViewModel(context: PreviewContainer.shared.mainContext))
    }
}
