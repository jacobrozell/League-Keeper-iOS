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
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(achievement.name), \(achievement.points) points")

                        ForEach(players, id: \.id) { player in
                            Toggle(isOn: Binding(
                                get: { isChecked(player.id, achievement.id) },
                                set: { _ in onToggle(player.id, achievement.id) }
                            )) {
                                Text(displayName(player))
                                    .font(.body)
                            }
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                            .disabled(isDisabled(player.id, achievement.id))
                            .accessibilityLabel("\(displayName(player)), \(achievement.name)")
                            .accessibilityValue(
                                isChecked(player.id, achievement.id) ? "checked" : "unchecked"
                            )
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
