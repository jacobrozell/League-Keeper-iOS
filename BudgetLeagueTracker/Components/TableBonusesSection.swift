import SwiftUI

/// Achievement toggles for all players at one table.
struct TableBonusesSection: View {
    let achievements: [Achievement]
    let players: [Player]
    let displayName: (Player) -> String
    let isChecked: (String, String) -> Bool
    let isDisabled: (String, String) -> Bool
    let onToggle: (String, String) -> Void

    var body: some View {
        if achievements.isEmpty {
            EmptyView()
        } else {
            Section {
                ForEach(achievements, id: \.id) { achievement in
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: achievement.iconName)
                                    .foregroundStyle(Color("BrandGold"))
                                Text(achievement.name)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text("+\(achievement.points)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            AchievementDescriptionText(description: achievement.achievementDescription)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(achievement.name), \(achievement.points) points")
                        .accessibilityHintIf(achievement.achievementDescription)

                        ForEach(players, id: \.id) { player in
                            let disabled = isDisabled(player.id, achievement.id)
                            VStack(alignment: .leading, spacing: 4) {
                                Toggle(isOn: Binding(
                                    get: { isChecked(player.id, achievement.id) },
                                    set: { _ in onToggle(player.id, achievement.id) }
                                )) {
                                    Text(displayName(player))
                                        .font(.body)
                                }
                                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                                .disabled(disabled)
                                .accessibilityLabel("\(displayName(player)), \(achievement.name)")
                                .accessibilityHintIf(achievement.achievementDescription)
                                .accessibilityValue(
                                    isChecked(player.id, achievement.id)
                                        ? "checked"
                                        : (disabled ? "disabled, already earned this week" : "unchecked")
                                )

                                if disabled {
                                    Text("Already earned this week")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                        .padding(.leading, 4)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Bonuses")
            } footer: {
                Text("Mark achievements earned at this table.")
                    .font(.caption)
            }
        }
    }
}
