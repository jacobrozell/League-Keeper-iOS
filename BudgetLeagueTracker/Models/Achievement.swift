import Foundation
import SwiftData

/// Represents an achievement that players can earn during games.
@Model
final class Achievement {
    /// Unique identifier for the achievement
    var id: String

    /// Achievement display name
    var name: String

    /// Points awarded when this achievement is earned
    var points: Int

    /// If true, this achievement is always available every week.
    /// If false, it may be randomly selected for a given week.
    var alwaysOn: Bool

    /// Short rule text shown at game night (optional).
    var achievementDescription: String?

    /// Raw category value (`AchievementCategory`).
    var categoryRaw: String = AchievementCategory.custom.rawValue

    /// SF Symbol name for list and scoring UI.
    var iconName: String = AppConstants.Achievement.defaultIconName

    /// Raw exclusivity value (`AchievementExclusivity`).
    var exclusivityRaw: String = AchievementExclusivity.unlimited.rawValue

    var category: AchievementCategory {
        get { AchievementCategory(rawValue: categoryRaw) ?? .custom }
        set { categoryRaw = newValue.rawValue }
    }

    var exclusivity: AchievementExclusivity {
        get { AchievementExclusivity(rawValue: exclusivityRaw) ?? .unlimited }
        set { exclusivityRaw = newValue.rawValue }
    }

    var availabilityLabel: String {
        alwaysOn ? "Every week" : "Random pool"
    }

    /// Creates a new achievement.
    init(
        id: String = UUID().uuidString,
        name: String,
        points: Int,
        alwaysOn: Bool = false,
        achievementDescription: String? = nil,
        category: AchievementCategory = .custom,
        iconName: String = AppConstants.Achievement.defaultIconName,
        exclusivity: AchievementExclusivity = .unlimited
    ) {
        self.id = id
        self.name = name
        self.points = points
        self.alwaysOn = alwaysOn
        self.achievementDescription = achievementDescription
        self.categoryRaw = category.rawValue
        self.iconName = iconName
        self.exclusivityRaw = exclusivity.rawValue
    }
}
