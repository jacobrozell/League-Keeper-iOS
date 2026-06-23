import SwiftUI

// MARK: - Achievements preview

struct RoundAchievementsPreviewContent: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let achievementsOnThisWeek: Bool
    let achievements: [Achievement]

    var body: some View {
        Group {
            if !achievementsOnThisWeek {
                Text("Achievements are not counted this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if achievements.isEmpty {
                Text("No achievements active this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(achievements, id: \.id) { achievement in
                    achievementRow(achievement)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func achievementRow(_ achievement: Achievement) -> some View {
        let description = AchievementDescriptionText(
            description: achievement.achievementDescription,
            style: .compact
        )

        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: achievement.iconName)
                            .foregroundStyle(Color("BrandGold"))
                            .frame(width: 24, alignment: .center)
                        Text(achievement.name)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 8)
                        Text("+\(achievement.points)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    description
                        .padding(.leading, 32)
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: achievement.iconName)
                        .foregroundStyle(Color("BrandGold"))
                        .frame(width: 24, alignment: .center)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(achievement.name)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 8)
                            Text("+\(achievement.points)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        description
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(achievement.name), \(achievement.points) points")
        .accessibilityHintIf(achievement.achievementDescription)
    }
}

struct RoundAchievementsPreviewSection: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        Section("This week's achievements") {
            RoundAchievementsPreviewContent(
                achievementsOnThisWeek: viewModel.achievementsOnThisWeek,
                achievements: viewModel.activeAchievements
            )
        }
    }
}

struct RoundAchievementsPreviewPanel: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week's achievements")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundAchievementsPreviewContent(
                achievementsOnThisWeek: viewModel.achievementsOnThisWeek,
                achievements: viewModel.activeAchievements
            )
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Weekly standings preview

struct RoundWeeklyStandingsPreviewContent: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        Group {
            ForEach(Array(viewModel.inlineWeeklyStandings.enumerated()), id: \.element.player.id) { index, item in
                HStack {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    Text(viewModel.displayName(for: item.player))
                    Spacer()
                    Text("\(item.points.total) pts")
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rank \(index + 1), \(viewModel.displayName(for: item.player)), \(item.points.total) points")
            }

            if viewModel.weeklyStandings.filter({ $0.points.total > 0 }).count > viewModel.inlineWeeklyStandings.count {
                Button("See full standings") {
                    viewModel.selectedStandingsWeek = viewModel.currentWeek
                    viewModel.setTab(.standings)
                }
                .font(.subheadline)
                .accessibilityLabel("See full standings for week \(viewModel.currentWeek)")
            }
        }
    }
}

struct RoundWeeklyStandingsPreviewSection: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        Section {
            RoundWeeklyStandingsPreviewContent(viewModel: viewModel)
        } header: {
            Text("Week \(viewModel.currentWeek) leaderboard")
        }
    }
}

struct RoundWeeklyStandingsPreviewPanel: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week \(viewModel.currentWeek) leaderboard")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundWeeklyStandingsPreviewContent(viewModel: viewModel)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Scoring bonuses (iPad sidebar)

struct RoundScoringBonusesPanel: View {
    @Bindable var viewModel: TournamentDetailViewModel

    var body: some View {
        let tableIndex = viewModel.currentScoringTableIndex
        let players = viewModel.playersForTable(at: tableIndex)

        VStack(alignment: .leading, spacing: 12) {
            Text("Bonuses")
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.activeAchievements, id: \.id) { achievement in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: achievement.iconName)
                                .foregroundStyle(Color("BrandGold"))
                            Text(achievement.name)
                                .font(.subheadline.weight(.semibold))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Text("+\(achievement.points)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        ForEach(players, id: \.id) { player in
                            let disabled = viewModel.isAchievementCheckDisabled(
                                playerId: player.id,
                                achievementId: achievement.id
                            )
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(isOn: Binding(
                                    get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                                    set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                                )) {
                                    Text(viewModel.displayName(for: player))
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                                .disabled(disabled)
                                .accessibilityLabel("\(viewModel.displayName(for: player)), \(achievement.name)")
                                .accessibilityHintIf(achievement.achievementDescription)
                                .accessibilityValue(
                                    viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id)
                                        ? "checked"
                                        : (disabled ? "disabled, already earned this week" : "unchecked")
                                )

                                if disabled {
                                    Text("Already earned this week")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Table rank row

struct TableRankRow: View {
    let rank: Int
    let name: String
    let placementLabel: String
    let canMoveUp: Bool
    let canMoveDown: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(placementLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(rank == 1 ? AppConstants.AccessibleColors.activeStatus : .secondary)
                .frame(width: 36, alignment: .leading)

            Text(name)
                .font(.body)

            Spacer()

            VStack(spacing: 4) {
                Button(action: onMoveUp) {
                    Image(systemName: "chevron.up")
                }
                .disabled(!canMoveUp)
                .accessibilityLabel("Move \(name) up")

                Button(action: onMoveDown) {
                    Image(systemName: "chevron.down")
                }
                .disabled(!canMoveDown)
                .accessibilityLabel("Move \(name) down")
            }
            .buttonStyle(.borderless)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placementLabel), \(name)")
        .accessibilityHint("Use the up and down buttons to change placement")
    }
}
