import SwiftUI

/// Table seating card with move-to-table actions for manual pod tweaks.
struct EditableTableSeatingCard: View {
    let tableNumber: Int
    let players: [Player]
    let displayName: (Player) -> String
    let tableCount: Int
    let onMovePlayer: (String, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Table \(tableNumber)")
                .font(.headline)

            ForEach(players, id: \.id) { player in
                HStack {
                    Text(displayName(player))
                        .font(.subheadline)

                    Spacer()

                    Menu {
                        ForEach(1...tableCount, id: \.self) { destination in
                            let destinationIndex = destination - 1
                            if destination != tableNumber {
                                Button("Move to Table \(destination)") {
                                    onMovePlayer(player.id, destinationIndex)
                                }
                            }
                        }
                    } label: {
                        Label("Move", systemImage: "arrow.left.arrow.right")
                            .font(.caption.weight(.semibold))
                            .labelStyle(.iconOnly)
                            .frame(minWidth: AppConstants.UI.minTouchTargetHeight, minHeight: 32)
                    }
                    .accessibilityLabel("Move \(displayName(player)) to another table")
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    List {
        EditableTableSeatingCard(
            tableNumber: 1,
            players: [
                Player(name: "Alice"),
                Player(name: "Bob"),
                Player(name: "Carol"),
                Player(name: "Dan")
            ],
            displayName: { $0.name },
            tableCount: 2,
            onMovePlayer: { _, _ in }
        )
    }
}
