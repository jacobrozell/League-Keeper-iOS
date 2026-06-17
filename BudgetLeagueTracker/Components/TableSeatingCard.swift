import SwiftUI

/// Visual density for table seating cards.
enum TableSeatingCardStyle {
    case compact
    case card
}

/// Summary card for a table's seated players before or after scoring.
struct TableSeatingCard: View {
    let tableNumber: Int
    let playerNames: [String]
    var isConfirmed: Bool = false
    var style: TableSeatingCardStyle = .compact

    var body: some View {
        Group {
            switch style {
            case .compact:
                compactBody
            case .card:
                cardBody
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    @ViewBuilder
    private var compactBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            tableHeader
            ForEach(Array(playerNames.enumerated()), id: \.offset) { _, name in
                Text(name)
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            tableHeader

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(Array(playerNames.enumerated()), id: \.offset) { _, name in
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(name)
                            .font(.body)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private var tableHeader: some View {
        HStack {
            Text("Table \(tableNumber)")
                .font(style == .card ? .title3.weight(.semibold) : .headline)
            Spacer()
            if isConfirmed {
                Label("Scored", systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Scored")
            }
        }
    }

    private var accessibilitySummary: String {
        let roster = playerNames.joined(separator: ", ")
        if isConfirmed {
            return "Table \(tableNumber), scored, \(roster)"
        }
        return "Table \(tableNumber), \(roster)"
    }
}

#Preview("Compact") {
    List {
        TableSeatingCard(tableNumber: 1, playerNames: ["Alice", "Bob", "Carol", "Dan"])
    }
}

#Preview("Card") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        TableSeatingCard(
            tableNumber: 1,
            playerNames: ["Alice", "Bob", "Carol", "Dan"],
            style: .card
        )
        TableSeatingCard(
            tableNumber: 2,
            playerNames: ["Eve", "Frank", "Grace", "Hank"],
            style: .card
        )
    }
    .padding()
}
