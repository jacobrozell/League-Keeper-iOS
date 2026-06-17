import SwiftUI

/// Head-to-head comparison against another league player.
struct PlayerHeadToHeadSection: View {
    let opponents: [Player]
    @Binding var selectedOpponentId: String?
    let record: HeadToHeadRecord?
    var playerName: String
    var opponentName: String?
    var opponentLabel: (Player) -> String = { $0.name }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Head-to-Head")
                .font(.headline)

            Text("Compare win records when two players sat at the same pod table — not a league format or partner preference.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if opponents.isEmpty {
                Text("Add more players to compare head-to-head records.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Picker("Compare with", selection: $selectedOpponentId) {
                    Text("Select player").tag(String?.none)
                    ForEach(opponents, id: \.id) { opponent in
                        Text(opponentLabel(opponent)).tag(Optional(opponent.id))
                    }
                }
                .accessibilityLabel("Compare with")

                if let record, let opponentName, record.totalGames > 0 {
                    Text(summaryText(record: record, opponentName: opponentName))
                        .font(.subheadline.weight(.semibold))
                        .accessibilityLabel(summaryText(record: record, opponentName: opponentName))
                } else if selectedOpponentId != nil {
                    Text("No shared pods yet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func summaryText(record: HeadToHeadRecord, opponentName: String) -> String {
        if record.player1Wins > record.player2Wins {
            return "\(playerName) leads \(opponentName) \(record.player1Wins)–\(record.player2Wins) in shared pods"
        }
        if record.player2Wins > record.player1Wins {
            return "\(opponentName) leads \(playerName) \(record.player2Wins)–\(record.player1Wins) in shared pods"
        }
        return "\(playerName) and \(opponentName) are tied \(record.player1Wins)–\(record.player2Wins) in shared pods"
    }
}

#Preview {
    Form {
        PlayerHeadToHeadSection(
            opponents: [Player(name: "Bob"), Player(name: "Charlie")],
            selectedOpponentId: .constant("2"),
            record: HeadToHeadRecord(player1Wins: 3, player2Wins: 1, ties: 0),
            playerName: "Alex",
            opponentName: "Bob"
        )
    }
}
