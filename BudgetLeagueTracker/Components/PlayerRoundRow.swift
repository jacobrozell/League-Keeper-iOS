import SwiftUI

/// Row for a player's recent round in match history.
struct PlayerRoundRow: View {
    let round: PlayerRoundSummary

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(round.tournamentName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(round.weekRoundLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(round.placementLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(round.isWin ? AppConstants.AccessibleColors.activeStatus : .primary)

                Text("\(round.totalPoints) pts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let outcome = round.isWin ? "win" : "placed \(round.placementLabel)"
        return "\(round.tournamentName), \(round.weekRoundLabel), \(outcome), \(round.totalPoints) points"
    }
}

#Preview {
    List {
        PlayerRoundRow(
            round: PlayerRoundSummary(
                id: "1",
                tournamentId: "t1",
                tournamentName: "Spring League",
                week: 2,
                round: 1,
                placement: 1,
                totalPoints: 6,
                achievementCount: 1,
                timestamp: Date(),
                isWin: true,
                podId: "pod1"
            )
        )
    }
}
