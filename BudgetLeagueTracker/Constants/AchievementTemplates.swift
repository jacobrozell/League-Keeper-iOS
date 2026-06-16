import Foundation

/// Curated achievement templates for the add flow.
enum AchievementTemplates {
    static let catalog: [AchievementTemplate] = [
        AchievementTemplate(
            id: "first-blood",
            name: "First Blood",
            achievementDescription: "First player to eliminate another player",
            points: 1,
            alwaysOn: false,
            category: .combat,
            iconName: "flame.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "combat-damage-master",
            name: "Combat Damage Master",
            achievementDescription: "Most combat damage dealt in the game",
            points: 2,
            alwaysOn: false,
            category: .combat,
            iconName: "bolt.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "five-color-flavor",
            name: "Five-Color Flavor",
            achievementDescription: "Your deck contains all five colors",
            points: 1,
            alwaysOn: true,
            category: .deckbuilding,
            iconName: "paintpalette.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "mono-master",
            name: "Mono Master",
            achievementDescription: "Your deck is a single color",
            points: 1,
            alwaysOn: false,
            category: .deckbuilding,
            iconName: "circle.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "combo-conductor",
            name: "Combo Conductor",
            achievementDescription: "Won with a combo or infinite loop",
            points: 2,
            alwaysOn: false,
            category: .deckbuilding,
            iconName: "sparkles",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "table-captain",
            name: "Table Captain",
            achievementDescription: "Kept the game moving and helped others",
            points: 1,
            alwaysOn: false,
            category: .social,
            iconName: "megaphone.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "good-sport",
            name: "Good Sport",
            achievementDescription: "Positive attitude win or lose",
            points: 1,
            alwaysOn: false,
            category: .social,
            iconName: "hand.thumbsup.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "chaos-agent",
            name: "Chaos Agent",
            achievementDescription: "Caused the most chaotic board state",
            points: 2,
            alwaysOn: false,
            category: .chaos,
            iconName: "dice.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "underdog-win",
            name: "Underdog Win",
            achievementDescription: "Won while behind on life or resources",
            points: 3,
            alwaysOn: false,
            category: .combat,
            iconName: "flag.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "perfect-round",
            name: "Perfect Round",
            achievementDescription: "Won without taking combat damage",
            points: 4,
            alwaysOn: false,
            category: .combat,
            iconName: "crown.fill",
            exclusivity: .onePerWeekPerPlayer
        ),
    ]
}
