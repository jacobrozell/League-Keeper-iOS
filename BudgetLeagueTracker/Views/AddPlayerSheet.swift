import SwiftUI

/// Sheet for adding a new player to the roster.
struct AddPlayerSheet: View {
    @Bindable var viewModel: PlayersViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Player name", text: $viewModel.newPlayerName)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .focused($isNameFocused)
                        .accessibilityLabel("Player name")
                        .accessibilityIdentifier("playerNameField")

                    TextField("Nickname (optional)", text: $viewModel.newPlayerNote)
                        .textContentType(.nickname)
                        .submitLabel(.done)
                        .accessibilityLabel("Nickname")
                        .accessibilityIdentifier("playerNicknameField")
                        .onSubmit { submit() }
                } footer: {
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    } else if let validationError = viewModel.addPlayerValidationError {
                        Text(validationError)
                            .foregroundStyle(.orange)
                    } else if let hint = viewModel.duplicateNameHint {
                        Text(hint)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Use a nickname when two players share a name (e.g. two Devans).")
                    }
                }

                Section {
                    PrimaryActionButton(title: "Add Player", action: submit, isDisabled: !viewModel.canAddPlayer)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.newPlayerName = ""
                        viewModel.newPlayerNote = ""
                        dismiss()
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func submit() {
        switch viewModel.addPlayer() {
        case .added:
            AppHaptics.success()
            dismiss()
        case .validationError(let message):
            errorMessage = message
        }
    }
}

#Preview {
    AddPlayerSheet(viewModel: PlayersViewModel(context: PreviewContainer.shared.mainContext))
}
