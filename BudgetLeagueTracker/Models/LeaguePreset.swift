import Foundation

/// Preset tournament rules applied when creating or switching league type.
enum LeaguePreset: String, CaseIterable, Identifiable, Codable, Sendable {
    case simpleLeague
    case budgetCommander

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .simpleLeague:
            return "Simple league"
        case .budgetCommander:
            return "Budget Commander (MTG)"
        }
    }

    var summaryLabel: String {
        switch self {
        case .simpleLeague:
            return "Simple league"
        case .budgetCommander:
            return "Budget Commander"
        }
    }

    var footer: String {
        switch self {
        case .simpleLeague:
            return "Entry fees, playstyle notes, and optional prizes — no deck budget fields."
        case .budgetCommander:
            return "Deck budget, pricing source, commander bracket, and MTG house rules."
        }
    }

    var showsDeckBudgetDetails: Bool {
        self == .budgetCommander
    }

    var defaultAchievementLibrary: AchievementTemplateLibrary {
        switch self {
        case .simpleLeague:
            return .generic
        case .budgetCommander:
            return .cardGame
        }
    }

    func defaultRules() -> TournamentRules {
        switch self {
        case .simpleLeague:
            return AppConstants.TournamentRulesDefaults.simpleLeagueRules
        case .budgetCommander:
            return AppConstants.TournamentRulesDefaults.defaultRules
        }
    }
}

/// Preset placement point scales for tournament scoring.
enum PlacementScalePreset: String, CaseIterable, Identifiable, Sendable {
    case standard
    case inverted
    case winnerTakeAll

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .standard: return "Standard (4–1)"
        case .inverted: return "Inverted (1–4)"
        case .winnerTakeAll: return "Winner take-all"
        }
    }

    var scale: [Int] {
        switch self {
        case .standard: return AppConstants.Scoring.defaultPlacementScale
        case .inverted: return [1, 2, 3, 4]
        case .winnerTakeAll: return [4, 0, 0, 0]
        }
    }
}
