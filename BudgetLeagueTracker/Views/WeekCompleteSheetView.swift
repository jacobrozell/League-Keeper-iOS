import SwiftUI

/// Lightweight week-end moment: shows weekly standings before continuing to the next week.
struct WeekCompleteSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.palette) private var palette

    let tournamentName: String
    let week: Int
    let standings: [(player: Player, points: Int, placementPoints: Int, achievementPoints: Int)]
    let nextWeek: Int
    var displayName: (Player) -> String = { $0.name }
    let onContinue: () -> Void

    private var shareText: String {
        let rows = standings.enumerated().map { index, standing in
            StandingsShareFormatter.WeeklyStanding(
                rank: index + 1,
                name: displayName(standing.player),
                totalPoints: standing.points,
                placementPoints: standing.placementPoints,
                achievementPoints: standing.achievementPoints
            )
        }
        return StandingsShareFormatter.weeklyStandings(
            tournamentName: tournamentName,
            week: week,
            standings: rows
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if standings.isEmpty {
                    EmptyStateView(
                        message: "Week \(week) complete",
                        hint: "No scores recorded for this week.",
                        systemImage: "flag.checkered"
                    )
                    .padding()
                } else {
                    List {
                        if let champion = standings.first {
                            Section {
                                VStack(alignment: .leading, spacing: 6) {
                                    Label {
                                        Text("Week \(week) champion: \(displayName(champion.player))")
                                            .font(.system(.headline, design: .serif).weight(.bold))
                                    } icon: {
                                        Image(systemName: "crown.fill")
                                    }
                                    .foregroundStyle(Color(hex: palette.gold))

                                    Text("\(champion.points) points this week")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Week \(week) champion, \(displayName(champion.player)), \(champion.points) points")
                            }
                        }

                        Section("Week \(week) standings") {
                            ForEach(Array(standings.enumerated()), id: \.element.player.id) { index, standing in
                                StandingsRow(
                                    rank: index + 1,
                                    name: displayName(standing.player),
                                    totalPoints: standing.points,
                                    placementPoints: standing.placementPoints,
                                    achievementPoints: standing.achievementPoints,
                                    wins: 0,
                                    mode: .weekly
                                )
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                PrimaryActionButton(title: "Continue to Week \(nextWeek)") {
                    onContinue()
                    dismiss()
                }
                .accessibilityIdentifier("weekCompleteContinue")
                .padding()
            }
            .navigationTitle("Week \(week) Complete")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !standings.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        ShareLink(
                            item: shareText,
                            subject: Text("\(tournamentName) — Week \(week)"),
                            message: Text(shareText)
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share week \(week) standings")
                        .accessibilityIdentifier("shareWeekStandings")
                    }
                }
            }
            .onAppear {
                AppHaptics.success()
                if let champion = standings.first {
                    AppAccessibility.announce("Week \(week) complete. \(displayName(champion.player)) leads with \(champion.points) points.")
                } else {
                    AppAccessibility.announce("Week \(week) complete. No scores recorded.")
                }
            }
        }
    }
}

#Preview {
    WeekCompleteSheetView(
        tournamentName: "Summer League",
        week: 1,
        standings: [],
        nextWeek: 2,
        onContinue: {}
    )
}
