import SwiftUI

/// Lets the host pick which scored round to edit, grouped by week.
struct EditRoundPickerView: View {
    let rounds: [EditableRoundOption]
    let currentWeek: Int
    var onSelect: (Int) -> Void
    var onCancel: () -> Void

    private var groupedWeeks: [(week: Int, rounds: [EditableRoundOption])] {
        let grouped = Dictionary(grouping: rounds, by: \.week)
        return grouped.keys.sorted().map { week in
            (week: week, rounds: grouped[week]?.sorted(by: { $0.round < $1.round }) ?? [])
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if rounds.isEmpty {
                    ContentUnavailableView(
                        "No rounds to edit",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Finish a round to fix table placements or achievements.")
                    )
                } else {
                    Section {
                        Text("Editing a round updates standings and player stats for that week.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(groupedWeeks, id: \.week) { group in
                        Section("Week \(group.week)") {
                            if group.week != currentWeek {
                                Text("Past week — standings will recalculate for week \(group.week).")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(group.rounds) { round in
                                Button {
                                    onSelect(round.snapshotIndex)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Round \(round.round)")
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
                                .accessibilityLabel("Week \(round.week) round \(round.round), \(round.detail)")
                                .accessibilityIdentifier("editRound-\(round.week)-\(round.round)")
                            }
                        }
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
            EditableRoundOption(snapshotIndex: 0, week: 1, round: 3, playerCount: 8),
            EditableRoundOption(snapshotIndex: 1, week: 2, round: 1, playerCount: 8)
        ],
        currentWeek: 2,
        onSelect: { _ in },
        onCancel: {}
    )
}
