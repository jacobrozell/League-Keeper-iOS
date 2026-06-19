import SwiftUI
import UIKit

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
                
                Section {
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

                    LabeledToggle(
                        title: "Standings-based seating",
                        isOn: $viewModel.editStandingsBasedSeating
                    )
                } header: {
                    Text("Settings")
                } footer: {
                    Text("Round 1 is always random. When on, rounds 2 and 3 group players by previous-round finish.")
                        .font(.caption)
                }

                TournamentRulesFormSection(rules: $viewModel.editRules)
                    .id(tournament.id)
            }
            .listStyle(.insetGrouped)
            .adaptiveContentWidth()
            .scrollDismissesKeyboard(.interactively)
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
                        viewModel.requestSaveEdit()
                    }
                    .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                    .disabled(viewModel.editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        dismissKeyboard()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .alert("Save tournament changes?", isPresented: $viewModel.showEditSaveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .destructive) {
                viewModel.saveEdit()
                dismiss()
            }
        } message: {
            Text(viewModel.pendingEditWarningMessages.joined(separator: "\n\n"))
        }
        .onChange(of: viewModel.editingTournament) { _, tournament in
            if tournament == nil { dismiss() }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    EditTournamentView(
        viewModel: TournamentsViewModel(context: PreviewContainer.shared.mainContext),
        tournament: Tournament(name: "Spring 2026", totalWeeks: 6, randomAchievementsPerWeek: 2)
    )
}
