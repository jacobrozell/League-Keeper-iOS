import Foundation

/// Category grouping for achievements (display and default icon suggestion).
enum AchievementCategory: String, Codable, CaseIterable, Identifiable, Sendable {
    case combat
    case deckbuilding
    case social
    case chaos
    case seasonal
    case custom

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .combat: return "Combat"
        case .deckbuilding: return "Deckbuilding"
        case .social: return "Social"
        case .chaos: return "Chaos"
        case .seasonal: return "Seasonal"
        case .custom: return "Custom"
        }
    }

    var defaultIconName: String {
        switch self {
        case .combat: return "flame.fill"
        case .deckbuilding: return "rectangle.stack.fill"
        case .social: return "person.3.fill"
        case .chaos: return "dice.fill"
        case .seasonal: return "leaf.fill"
        case .custom: return "trophy.fill"
        }
    }
}

/// Who may earn an achievement in a given context.
enum AchievementExclusivity: String, Codable, CaseIterable, Identifiable, Sendable {
    case unlimited
    case onePerPod
    case onePerWeekPerPlayer

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .unlimited: return "Anyone can earn"
        case .onePerPod: return "One player per pod"
        case .onePerWeekPerPlayer: return "Once per week per player"
        }
    }

    var footnote: String {
        switch self {
        case .unlimited:
            return "Multiple players can earn full points in the same pod."
        case .onePerPod:
            return "Only one player in a pod can earn this each round."
        case .onePerWeekPerPlayer:
            return "Each player can earn this at most once per week."
        }
    }
}

/// UI preset for achievement point values.
enum AchievementPointsTier: String, CaseIterable, Identifiable, Sendable {
    case small
    case standard
    case big
    case trophy

    var id: String { rawValue }

    var points: Int {
        switch self {
        case .small: return 1
        case .standard: return 2
        case .big: return 3
        case .trophy: return 4
        }
    }

    var displayName: String {
        switch self {
        case .small: return "Small bonus"
        case .standard: return "Standard"
        case .big: return "Big swing"
        case .trophy: return "Trophy"
        }
    }

    var placementContext: String {
        switch self {
        case .small: return "About half a 4th-place finish"
        case .standard: return "Like moving up one placement"
        case .big: return "Worth a full placement jump"
        case .trophy: return "Rare or hard to earn"
        }
    }

    static func tier(for points: Int) -> AchievementPointsTier? {
        allCases.first { $0.points == points }
    }
}

/// Non-persisted template used to seed the achievement form.
struct AchievementTemplate: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let achievementDescription: String
    let points: Int
    let alwaysOn: Bool
    let category: AchievementCategory
    let iconName: String
    let exclusivity: AchievementExclusivity
}

/// How the achievement form sheet is presented.
enum AchievementFormMode: Equatable, Identifiable, Sendable {
    case add(template: AchievementTemplate?)
    case edit(achievementId: String)
    case duplicate(achievementId: String)

    var id: String {
        switch self {
        case .add(let template):
            return "add-\(template?.id ?? "blank")"
        case .edit(let achievementId):
            return "edit-\(achievementId)"
        case .duplicate(let achievementId):
            return "duplicate-\(achievementId)"
        }
    }
}
