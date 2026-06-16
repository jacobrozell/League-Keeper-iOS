import SwiftUI

/// Hero identity header for player detail.
struct PlayerIdentityCard: View {
    let name: String
    let playerId: String
    var leagueRank: Int?
    var winRateText: String
    var lastPlayedText: String?
    var highlightText: String?

    var body: some View {
        VStack(spacing: 12) {
            PlayerAvatarView(name: name, playerId: playerId, size: .large)

            Text(name)
                .font(.system(.title2, design: .serif).weight(.bold))
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                if let leagueRank {
                    Label("#\(leagueRank) in league", systemImage: "trophy.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(
                            leagueRank == 1
                                ? AppConstants.AccessibleColors.winnerAccent
                                : AppConstants.AccessibleColors.activeStatus
                        )
                }

                Label(winRateText, systemImage: "percent")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let highlightText {
                Text(highlightText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppConstants.AccessibleColors.winnerAccent)
            }

            if let lastPlayedText {
                Text(lastPlayedText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PlayerIdentityCard(
        name: "Alex Johnson",
        playerId: "1",
        leagueRank: 1,
        winRateText: "42.0% win rate",
        lastPlayedText: "Last played 2 days ago",
        highlightText: "3 wins in a row"
    )
    .padding()
}
