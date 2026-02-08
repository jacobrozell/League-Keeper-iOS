import SwiftUI

/// Tournaments view - displays list of ongoing and completed tournaments.
/// This is the main entry point of the app (renamed from Dashboard).
struct TournamentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: TournamentsViewModel
    @Binding var navigationPath: [Tournament]
    
    var body: some View {
        Group {
            if viewModel.hasTournaments {
                tournamentsList
            } else {
                emptyState
            }
        }
        .navigationTitle("Tournaments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.createNewTournament()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add tournament")
                .accessibilityIdentifier("Add")
            }
        }
        .sheet(isPresented: $viewModel.showNewTournamentSheet, onDismiss: {
            viewModel.dismissNewTournamentSheet()
        }) {
            if let vm = viewModel.newTournamentSheetViewModel {
                NewTournamentView(viewModel: vm, isSheetMode: true, onCreated: {
                    viewModel.dismissNewTournamentSheet()
                }, onCancel: {
                    viewModel.dismissNewTournamentSheet()
                })
            }
        }
        .sheet(item: $viewModel.editingTournament, onDismiss: {
            viewModel.editingTournament = nil
        }) { tournament in
            EditTournamentView(viewModel: viewModel, tournament: tournament)
        }
        .sheet(item: $viewModel.completedTournamentForSheet, onDismiss: {
            viewModel.closeCompletedStandingsSheet()
        }) { tournament in
            completedStandingsSheet(tournament: tournament)
        }
        .alert("Delete Tournament", isPresented: Binding(
            get: { viewModel.tournamentToDelete != nil },
            set: { if !$0 { viewModel.tournamentToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                viewModel.tournamentToDelete = nil
            }
            Button("Delete", role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text("Delete this tournament? This cannot be undone.")
        }
        .onAppear {
            viewModel.refresh()
        }
    }
    
    // MARK: - Tournament List
    
    @ViewBuilder
    private var tournamentsList: some View {
        List {
            // Ongoing tournaments section
            if viewModel.hasOngoingTournaments {
                Section("Ongoing") {
                    ForEach(viewModel.ongoingTournaments, id: \.id) { tournament in
                        NavigationLink(value: tournament) {
                            TournamentCell(
                                tournament: tournament,
                                playerCount: viewModel.playerCount(for: tournament),
                                winnerName: nil
                            )
                        }
                        .contextMenu {
                            Button {
                                viewModel.openEdit(tournament)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                viewModel.requestDelete(tournament)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            
            // Completed tournaments section (tap opens standings sheet, not push)
            if viewModel.hasCompletedTournaments {
                Section("Completed") {
                    ForEach(viewModel.completedTournaments, id: \.id) { tournament in
                        Button {
                            viewModel.openCompletedStandings(tournament)
                        } label: {
                            TournamentCell(
                                tournament: tournament,
                                playerCount: viewModel.playerCount(for: tournament),
                                winnerName: viewModel.winnerName(for: tournament)
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                viewModel.openEdit(tournament)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                viewModel.requestDelete(tournament)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    @ViewBuilder
    private func completedStandingsSheet(tournament: Tournament) -> some View {
        TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: modelContext))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("See full detail") {
                        navigationPath.append(tournament)
                        viewModel.closeCompletedStandingsSheet()
                    }
                }
            }
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            EmptyStateView(
                message: "No tournaments yet",
                hint: "Tap the + button to create your first tournament."
            )
            
            Spacer()
            
            PrimaryActionButton(
                title: "Create Tournament",
                action: { viewModel.createNewTournament() },
                accessibilityLabel: "Create Tournament"
            )
            .accessibilityIdentifier("Create Tournament")
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    NavigationStack {
        TournamentsView(viewModel: TournamentsViewModel(context: PreviewContainer.shared.mainContext), navigationPath: .constant([]))
    }
}
