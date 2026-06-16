import SwiftUI

/// A row component for displaying an achievement in the Achievements list.
struct AchievementListRow: View {
    let achievement: Achievement
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onToggleAlwaysOn: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(Color("BrandGold"))
                    .frame(width: 36, height: 36)
                    .background(Color("BrandGold").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let description = achievement.achievementDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 8) {
                        Text("\(achievement.points) pts")
                            .font(.caption)
                            .foregroundStyle(AppConstants.AccessibleColors.captionText)

                        Text(achievement.availabilityLabel)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                achievement.alwaysOn
                                    ? AppConstants.AccessibleColors.activeStatusBackground
                                    : Color(.secondarySystemBackground)
                            )
                            .foregroundStyle(
                                achievement.alwaysOn
                                    ? AppConstants.AccessibleColors.activeStatus
                                    : .secondary
                            )
                            .clipShape(Capsule())

                        Text(achievement.category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer(minLength: 8)

                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(action: onDuplicate) {
                        Label("Duplicate", systemImage: "plus.square.on.square")
                    }
                    Button(action: onToggleAlwaysOn) {
                        Label(
                            achievement.alwaysOn ? "Move to random pool" : "Available every week",
                            systemImage: achievement.alwaysOn ? "shuffle" : "checkmark.circle"
                        )
                    }
                    Button(role: .destructive, action: onRemove) {
                        Label("Remove", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                        .frame(minWidth: AppConstants.UI.minTouchTargetHeight, minHeight: AppConstants.UI.minTouchTargetHeight)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Options for \(achievement.name)")
            }
            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("achievement-row-\(achievement.name)")
    }
}

#Preview {
    List {
        AchievementListRow(
            achievement: Achievement(
                name: "First Blood",
                points: 1,
                achievementDescription: "First player to eliminate another player",
                category: .combat,
                iconName: "flame.fill",
                exclusivity: .onePerPod
            ),
            onEdit: {},
            onDuplicate: {},
            onToggleAlwaysOn: {},
            onRemove: {}
        )
    }
    .listStyle(.insetGrouped)
}
