import SwiftUI

/// Edit Tournament view - sheet to edit name, weeks, and random achievements per week.
struct EditTournamentView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: TournamentsViewModel
    let tournament: Tournament
    
    var body: some View {
        NavigationStack {
            List {
                Section("Tournament Name") {
                    TextField("Tournament name", text: $viewModel.editName)
                        .textContentType(.organizationName)
                }
                
                Section("Settings") {
                    LabeledStepper(
                        title: "Weeks",
                        value: $viewModel.editWeeks,
                        range: AppConstants.League.weeksRange
                    )
                    
                    LabeledStepper(
                        title: "Random achievements/week",
                        value: $viewModel.editRandomPerWeek,
                        range: AppConstants.League.randomAchievementsPerWeekRange
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Edit Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.editingTournament = nil
                        dismiss()
                    }
                    .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEdit()
                        dismiss()
                    }
                    .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                    .disabled(viewModel.editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    EditTournamentView(
        viewModel: TournamentsViewModel(context: PreviewContainer.shared.mainContext),
        tournament: Tournament(name: "Spring 2026", totalWeeks: 6, randomAchievementsPerWeek: 2)
    )
}
