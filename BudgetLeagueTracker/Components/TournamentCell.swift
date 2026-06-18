import SwiftUI

/// A cell displaying tournament information in a list.
/// Shows different information based on tournament status.
struct TournamentCell: View {
    let tournament: Tournament
    let subtitle: String
    let winnerName: String?

    @Environment(\.palette) private var palette

    init(tournament: Tournament, playerCount: Int, winnerName: String?) {
        self.tournament = tournament
        self.winnerName = winnerName
        switch tournament.status {
        case .ongoing:
            self.subtitle = "Week \(tournament.currentWeek) of \(tournament.totalWeeks) · \(playerCount) players"
        case .completed:
            if let winner = winnerName {
                self.subtitle = "Winner: \(winner) · \(tournament.totalWeeks) weeks"
            } else {
                self.subtitle = "\(tournament.totalWeeks) weeks · \(tournament.dateRangeString)"
            }
        }
    }

    init(tournament: Tournament, subtitle: String, winnerName: String?) {
        self.tournament = tournament
        self.subtitle = subtitle
        self.winnerName = winnerName
    }

    var body: some View {
        HStack(spacing: 12) {
            tournamentIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(tournament.name)
                    .font(.system(.body, design: .serif).weight(.semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility5)

            Spacer(minLength: 8)

            if tournament.status == .ongoing {
                StatusChip(
                    label: "Active",
                    colorHex: "#34C759",
                    accessibilityPrefix: "Tournament status"
                )
            } else if winnerName != nil {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundStyle(Color(hex: palette.gold))
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tournament.name), \(subtitle)")
    }

    // MARK: - Icon

    @ViewBuilder
    private var tournamentIcon: some View {
        let isCompleted = tournament.status == .completed
        let accentHex = isCompleted ? palette.gold : "#007AFF"
        Image(systemName: isCompleted ? "trophy.fill" : "flag.fill")
            .font(.body.weight(.semibold))
            .foregroundStyle(Color(hex: accentHex))
            .frame(width: 36, height: 36)
            .background(
                Color(hex: accentHex).opacity(0.12),
                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

#Preview("Ongoing Tournament") {
    List {
        TournamentCell(
            tournament: Tournament(
                name: "Spring 2026 League",
                totalWeeks: 8,
                currentWeek: 3
            ),
            subtitle: "Resume Week 3 · 12 players · 2 achievements",
            winnerName: nil
        )
    }
    .listStyle(.insetGrouped)
}

#Preview("Completed Tournament") {
    List {
        TournamentCell(
            tournament: Tournament(
                name: "Winter 2025 League",
                totalWeeks: 6,
                status: .completed
            ),
            playerCount: 10,
            winnerName: "Alice"
        )
    }
    .listStyle(.insetGrouped)
}
