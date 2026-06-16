import SwiftUI

/// Sheet for editing a player's name and optional nickname.
struct PlayerEditNameSheet: View {
    @Bindable var viewModel: PlayerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var nameNote: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Player name", text: $name)
                        .textContentType(.name)
                        .submitLabel(.next)
                        .accessibilityLabel("Player name")
                        .onSubmit { save() }

                    TextField("Nickname (optional)", text: $nameNote)
                        .textContentType(.nickname)
                        .submitLabel(.done)
                        .accessibilityLabel("Nickname")
                        .onSubmit { save() }
                } footer: {
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    } else {
                        Text("Nicknames help when two players share a name, e.g. Devan (Smith) and Devan (Jones).")
                    }
                }
            }
            .navigationTitle("Edit Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                name = viewModel.player.name
                nameNote = viewModel.player.nameNote ?? ""
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        switch viewModel.updatePlayer(name: name, nameNote: nameNote) {
        case .success:
            dismiss()
        case .failure(let error):
            errorMessage = error
        }
    }
}

#Preview {
    PlayerEditNameSheet(
        viewModel: PlayerDetailViewModel(
            context: PreviewContainer.shared.mainContext,
            player: Player(name: "Test Player")
        )
    )
}
