import SwiftUI

/// View for editing the last completed round.
/// Allows modification of placements and achievements before saving changes.
struct EditLastRoundView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EditLastRoundViewModel
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            content
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
                            viewModel.save()
                            onSave()
                            dismiss()
                        }
                    }
                }
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
            Text(player.name)
                .font(.headline)
                .accessibilityHidden(true)
            
            PlacementPicker(
                playerName: player.name,
                selection: Binding(
                    get: { viewModel.placement(for: player.id) },
                    set: { viewModel.setPlacement(for: player.id, place: $0) }
                ),
                isDisabled: false
            )
            
            if viewModel.achievementsEnabled && !viewModel.achievements.isEmpty {
                ForEach(viewModel.achievements, id: \.id) { achievement in
                    AchievementCheckItem(
                        name: achievement.name,
                        points: achievement.points,
                        iconName: achievement.iconName,
                        achievementDescription: achievement.achievementDescription,
                        exclusivity: achievement.exclusivity,
                        isChecked: Binding(
                            get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                            set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                        )
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
        onSave: {}
    )
}
