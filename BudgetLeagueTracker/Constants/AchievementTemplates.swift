import Foundation

/// Template catalog grouping for the achievement add flow.
enum AchievementTemplateLibrary: String, CaseIterable, Identifiable, Sendable {
    case generic
    case cardGame

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .generic: return "Generic"
        case .cardGame: return "Card game"
        }
    }
}

/// Curated achievement templates for the add flow.
enum AchievementTemplates {
    static let genericCatalog: [AchievementTemplate] = [
        AchievementTemplate(
            id: "table-captain-generic",
            name: "Table Captain",
            achievementDescription: "Kept the game moving and helped others",
            points: 1,
            alwaysOn: false,
            category: .social,
            iconName: "megaphone.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "good-sport-generic",
            name: "Good Sport",
            achievementDescription: "Positive attitude win or lose",
            points: 1,
            alwaysOn: false,
            category: .social,
            iconName: "hand.thumbsup.fill",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "comeback-king",
            name: "Comeback King",
            achievementDescription: "Won from a losing position",
            points: 2,
            alwaysOn: false,
            category: .combat,
            iconName: "flag.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "underdog-win-generic",
            name: "Underdog Win",
            achievementDescription: "Won while clearly behind",
            points: 3,
            alwaysOn: false,
            category: .combat,
            iconName: "flag.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "perfect-round-generic",
            name: "Perfect Round",
            achievementDescription: "Flawless or dominant performance",
            points: 4,
            alwaysOn: false,
            category: .combat,
            iconName: "crown.fill",
            exclusivity: .onePerWeekPerPlayer
        ),
        AchievementTemplate(
            id: "most-creative",
            name: "Most Creative",
            achievementDescription: "Most creative or memorable play",
            points: 2,
            alwaysOn: false,
            category: .chaos,
            iconName: "wand.and.stars",
            exclusivity: .unlimited
        ),
        AchievementTemplate(
            id: "hosts-choice",
            name: "Host's Choice",
            achievementDescription: "Organizer's pick for standout moment",
            points: 2,
            alwaysOn: false,
            category: .social,
            iconName: "star.fill",
            exclusivity: .onePerPod
        ),
        AchievementTemplate(
            id: "mvp",
            name: "MVP",
            achievementDescription: "Best overall contribution this round",
            points: 2,
            alwaysOn: false,
            category: .social,
            iconName: "medal.fill",
            exclusivity: .onePerPod
        ),
    ]

    static let cardGameCatalog: [AchievementTemplate] = [
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

    /// All templates (legacy accessor for tests migrating to library-specific APIs).
    static var catalog: [AchievementTemplate] {
        genericCatalog + cardGameCatalog
    }

    static func templates(for library: AchievementTemplateLibrary) -> [AchievementTemplate] {
        switch library {
        case .generic: return genericCatalog
        case .cardGame: return cardGameCatalog
        }
    }
}
