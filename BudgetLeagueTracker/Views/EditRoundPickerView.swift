import SwiftUI

/// Lets the host pick which scored round from the current week to edit.
struct EditRoundPickerView: View {
    let rounds: [EditableRoundOption]
    var onSelect: (Int) -> Void
    var onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                if rounds.isEmpty {
                    ContentUnavailableView(
                        "No rounds to edit",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Finish a round this week to fix placements or achievements.")
                    )
                } else {
                    Section {
                        ForEach(rounds) { round in
                            Button {
                                onSelect(round.snapshotIndex)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(round.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text(round.detail)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .accessibilityLabel("\(round.title), \(round.detail)")
                            .accessibilityIdentifier("editRound-\(round.round)")
                        }
                    } footer: {
                        Text("Changes update standings and player stats for that round.")
                            .font(.caption)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .adaptiveContentWidth()
            .navigationTitle("Edit Scored Round")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

struct EditableRoundOption: Identifiable, Equatable {
    let snapshotIndex: Int
    let week: Int
    let round: Int
    let playerCount: Int

    var id: Int { snapshotIndex }

    var title: String {
        "Week \(week) · Round \(round)"
    }

    var detail: String {
        "\(playerCount) players scored"
    }
}

#Preview {
    EditRoundPickerView(
        rounds: [
            EditableRoundOption(snapshotIndex: 0, week: 2, round: 1, playerCount: 8),
            EditableRoundOption(snapshotIndex: 1, week: 2, round: 2, playerCount: 8)
        ],
        onSelect: { _ in },
        onCancel: {}
    )
}
