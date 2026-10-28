import SwiftUI

/// View for editing the last completed round.
/// Allows modification of placements and achievements before saving changes.
struct EditLastRoundView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EditLastRoundViewModel
    var onSave: (Int) -> Void
    @State private var saveFailed = false
    
    var body: some View {
        NavigationStack {
            content
                .adaptiveContentWidth()
                .navigationTitle(viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            guard viewModel.save() else {
                                saveFailed = true
                                return
                            }
                            onSave(viewModel.roundNumber)
                            dismiss()
                        }
                        .disabled(!viewModel.hasValidPlacements)
                    }
                }
        }
        .alert("Couldn't Save", isPresented: $saveFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(PersistenceError.saveFailed.toastMessage)
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if viewModel.hasRoundToEdit {
            List {
                // Header
                Section {
                    Text(viewModel.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(viewModel.subtitle)
                }
                
                // Players
                Section("Players") {
                    ForEach(viewModel.players, id: \.id) { player in
                        playerRow(player)
                    }
                }

                if !viewModel.hasValidPlacements {
                    Section {
                        Text("Each player needs a different finish place from 1st through \(viewModel.maxPlacement).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
        } else {
            ContentUnavailableView(
                "No Round to Edit",
                systemImage: "clock.arrow.circlepath",
                description: Text("Complete a round first to edit it.")
            )
        }
    }
    
    // MARK: - Player Row
    
    @ViewBuilder
    private func playerRow(_ player: Player) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.displayName(for: player))
                .font(.headline)
                .accessibilityHidden(true)
            
            PlacementPicker(
                playerName: viewModel.displayName(for: player),
                selection: Binding(
                    get: { viewModel.placement(for: player.id) },
                    set: { viewModel.setPlacement(for: player.id, place: $0) }
                ),
                maxPlace: viewModel.maxPlacement,
                isDisabled: false
            )
            
            if viewModel.achievementsEnabled && !viewModel.achievements.isEmpty {
                ForEach(viewModel.achievements, id: \.id) { achievement in
                    let disabled = viewModel.isAchievementCheckDisabled(playerId: player.id, achievementId: achievement.id)
                    AchievementCheckItem(
                        name: achievement.name,
                        points: achievement.points,
                        iconName: achievement.iconName,
                        achievementDescription: achievement.achievementDescription,
                        exclusivity: achievement.exclusivity,
                        isChecked: Binding(
                            get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                            set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                        ),
                        isDisabled: disabled,
                        disabledReason: disabled ? "Already earned this week" : nil
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EditLastRoundView(
        viewModel: EditLastRoundViewModel(
            context: PreviewContainer.shared.mainContext,
            tournamentId: "preview"
        ),
        onSave: { _ in }
    )
}
