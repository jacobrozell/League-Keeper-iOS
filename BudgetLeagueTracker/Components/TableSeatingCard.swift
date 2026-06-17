import SwiftUI

/// Summary card for a table's seated players before or after scoring.
struct TableSeatingCard: View {
    let tableNumber: Int
    let playerNames: [String]
    var isConfirmed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Table \(tableNumber)")
                    .font(.headline)
                Spacer()
                if isConfirmed {
                    Label("Scored", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Scored")
                }
            }

            ForEach(Array(playerNames.enumerated()), id: \.offset) { _, name in
                Text(name)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        let roster = playerNames.joined(separator: ", ")
        if isConfirmed {
            return "Table \(tableNumber), scored, \(roster)"
        }
        return "Table \(tableNumber), \(roster)"
    }
}

#Preview {
    List {
        TableSeatingCard(tableNumber: 1, playerNames: ["Alice", "Bob", "Carol", "Dan"])
        TableSeatingCard(tableNumber: 2, playerNames: ["Eve", "Frank", "Grace"], isConfirmed: true)
    }
}
