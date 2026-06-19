import SwiftUI
import UIKit

/// New Tournament view - create a new tournament with name, settings, and player selection.
struct NewTournamentView: View {
    @Bindable var viewModel: NewTournamentViewModel
    var isSheetMode: Bool = false
    var onCreated: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    @State private var toastMessage: String?
    
    var body: some View {
        List {
            // Tournament Name
            Section("Tournament Name") {
                TextField("e.g., Spring 2026 League", text: $viewModel.tournamentName)
                    .textContentType(.organizationName)
            }
            
            // Settings
            Section {
                LabeledStepper(
                    title: "Weeks",
                    value: $viewModel.totalWeeks,
                    range: AppConstants.League.weeksRange
                )
                
                LabeledStepper(
                    title: "Random achievements/week",
                    value: $viewModel.randomAchievementsPerWeek,
                    range: AppConstants.League.randomAchievementsPerWeekRange
                )

                LabeledToggle(
                    title: "Standings-based seating",
                    isOn: $viewModel.standingsBasedSeating
                )
            } header: {
                Text("Settings")
            } footer: {
                Text("Round 1 is always random. When on, rounds 2 and 3 group players by where they finished last round (1sts at table 1, 2nds at table 2, and so on).")
                    .font(.caption)
            }

            TournamentRulesFormSection(rules: $viewModel.rules)
            
            // Players
            Section {
                if viewModel.filteredPlayers.isEmpty, !viewModel.searchText.isEmpty {
                    Text("No players match your search.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.filteredPlayers, id: \.id) { player in
                        PlayerRow(
                            name: viewModel.displayName(for: player),
                            mode: .toggleable(
                                isOn: Binding(
                                    get: { viewModel.isSelected(player) },
                                    set: { _ in viewModel.togglePlayer(player) }
                                )
                            )
                        )
                    }
                }
                
                addPlayerRow
            } header: {
                HStack {
                    Text("Players")
                    Spacer()
                    Text("\(viewModel.selectedPlayerCount) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Create Button
            Section {
                PrimaryActionButton(title: "Create Tournament") {
                    if viewModel.createTournament(), isSheetMode {
                        onCreated?()
                    }
                }
                .accessibilityIdentifier("Submit Create Tournament")
                .disabled(!viewModel.canCreateTournament)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } footer: {
                if viewModel.selectedPlayerIds.isEmpty {
                    Text("Select at least one player to create the tournament.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .adaptiveContentWidth()
        .searchable(text: $viewModel.searchText, prompt: "Search players")
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("New Tournament")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if isSheetMode {
                        onCancel?()
                    } else {
                        viewModel.cancel()
                    }
                } label: {
                    Text("Cancel")
                        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                }
                .accessibilityIdentifier("Cancel")
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .onPersistenceError(viewModel.persistenceErrorMessage, showToast: showToast, clearError: viewModel.clearPersistenceError)
        .toastOverlay(toastMessage)
    }

    private func showToast(_ message: String) {
        ToastPresentation.show(message, binding: $toastMessage)
    }
    
    // MARK: - Add Player Row
    
    @ViewBuilder
    private var addPlayerRow: some View {
        HStack {
            TextField("Add player", text: $viewModel.newPlayerName)
                .textContentType(.name)
                .submitLabel(.done)
                .accessibilityLabel("Add player")
                .accessibilityIdentifier("newTournamentAddPlayerField")
                .onSubmit {
                    viewModel.addPlayer()
                }
            
            Button {
                viewModel.addPlayer()
            } label: {
                Text("Add")
                    .frame(minWidth: AppConstants.UI.minTouchTargetHeight, minHeight: AppConstants.UI.minTouchTargetHeight)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canAddPlayer)
            .accessibilityLabel("Add player")
            .accessibilityIdentifier("Add player")
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack {
        NewTournamentView(viewModel: NewTournamentViewModel(context: PreviewContainer.shared.mainContext))
    }
}
