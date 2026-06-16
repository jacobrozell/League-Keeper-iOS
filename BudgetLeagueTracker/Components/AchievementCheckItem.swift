import SwiftUI

/// A toggle item for checking an achievement during pod scoring.
struct AchievementCheckItem: View {
    let name: String
    let points: Int
    let iconName: String
    let achievementDescription: String?
    let exclusivity: AchievementExclusivity
    @Binding var isChecked: Bool
    var isDisabled: Bool = false
    var disabledReason: String?

    init(
        name: String,
        points: Int,
        iconName: String = AppConstants.Achievement.defaultIconName,
        achievementDescription: String? = nil,
        exclusivity: AchievementExclusivity = .unlimited,
        isChecked: Binding<Bool>,
        isDisabled: Bool = false,
        disabledReason: String? = nil
    ) {
        self.name = name
        self.points = points
        self.iconName = iconName
        self.achievementDescription = achievementDescription
        self.exclusivity = exclusivity
        self._isChecked = isChecked
        self.isDisabled = isDisabled
        self.disabledReason = disabledReason
    }

    var body: some View {
        Toggle(isOn: $isChecked) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(name)
                            .font(.body)
                        Text("+\(points)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let achievementDescription, !achievementDescription.isEmpty {
                        Text(achievementDescription)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(2)
                    } else if let disabledReason, isDisabled {
                        Text(disabledReason)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        .disabled(isDisabled)
        .accessibilityLabel("\(name), \(points) points")
        .accessibilityValue(isChecked ? "checked" : (isDisabled ? "disabled" : "unchecked"))
    }
}

#Preview {
    List {
        AchievementCheckItem(
            name: "First Blood",
            points: 1,
            iconName: "flame.fill",
            achievementDescription: "First player to eliminate another player",
            exclusivity: .onePerPod,
            isChecked: .constant(true)
        )
        AchievementCheckItem(
            name: "Perfect Round",
            points: 4,
            iconName: "crown.fill",
            isChecked: .constant(false),
            isDisabled: true,
            disabledReason: "Already earned this week"
        )
    }
    .listStyle(.insetGrouped)
}
