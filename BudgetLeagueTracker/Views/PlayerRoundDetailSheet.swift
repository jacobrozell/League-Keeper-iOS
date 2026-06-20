import SwiftUI

/// Sheet showing full context for a single scored round.
struct PlayerRoundDetailSheet: View {
    let detail: PlayerRoundDetail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(detail.summary.tournamentName)
                                .font(.headline)
                            Text(detail.summary.weekRoundLabel)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(detail.summary.placementLabel)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(detail.summary.isWin ? AppConstants.AccessibleColors.activeStatus : .primary)
                            Text("\(detail.summary.totalPoints) pts total")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Points") {
                    LabeledContent("Placement", value: "\(detail.placementPoints)")
                    LabeledContent("Achievements", value: "\(detail.achievementPoints)")
                }

                if !detail.achievements.isEmpty {
                    Section("Achievements Earned") {
                        ForEach(detail.achievements, id: \.self) { name in
                            Label(name, systemImage: "star.fill")
                                .foregroundStyle(AppConstants.AccessibleColors.achievementAccent)
                        }
                    }
                }

                Section("Table") {
                    ForEach(detail.podmates) { podmate in
                        HStack {
                            Text(podmate.playerName)
                                .fontWeight(podmate.isSelf ? .bold : .regular)
                            Spacer()
                            Text(podmate.placementLabel)
                                .foregroundStyle(podmate.placement == 1 ? AppConstants.AccessibleColors.activeStatus : .secondary)
                            Text("\(podmate.totalPoints) pts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Round Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PlayerRoundDetailSheet(
        detail: PlayerRoundDetail(
            summary: PlayerRoundSummary(
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
            ),
            placementPoints: 4,
            achievementPoints: 2,
            achievements: ["First Blood"],
            podmates: [
                PodmateResult(playerName: "Alex", placement: 1, totalPoints: 6, isSelf: true),
                PodmateResult(playerName: "Bob", placement: 2, totalPoints: 4, isSelf: false)
            ]
        )
    )
}
