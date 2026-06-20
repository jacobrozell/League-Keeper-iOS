import Foundation
import SwiftUI

/// Centralized constants for the Budget League Tracker app.
/// All magic numbers and literal strings are defined here for consistency and testability.
enum AppConstants {
    
    // MARK: - UI / Accessibility
    
    enum UI {
        /// Minimum touch target height per iOS HIG (44pt)
        static let minTouchTargetHeight: CGFloat = 44
    }

    /// User-facing terminology (internal code may still use "pod").
    enum Copy {
        static let tableSingular = "table"
        static let tablePlural = "tables"
        static let seatPlayers = "Seat players"
        static let scoreRound = "Score round"
        static let onePerTable = "One player per table"
        static let onePerTableFootnote = "Only one player at a table can earn this each round."
        static let unlimitedFootnote = "Multiple players can earn full points at the same table."
    }

    enum Player {
        /// Optional nickname shown when distinguishing same-name players.
        static let nameNoteMaxLength = 32
    }
    
    // MARK: - Accessible Colors
    
    /// Colors that meet WCAG 2.1 AA contrast requirements and adapt to light/dark mode
    enum AccessibleColors {
        /// Secondary text color with improved contrast (4.5:1 ratio minimum)
        static let secondaryText = Color(uiColor: .secondaryLabel)
        
        /// Caption text color with improved contrast
        static let captionText = Color(uiColor: .secondaryLabel)
        
        /// Hint text color - uses secondary label for accessibility
        static let hintText = Color(uiColor: .secondaryLabel)
        
        /// Active/green status color with sufficient contrast
        static let activeStatus = Color(uiColor: .systemGreen)
        
        /// Background for active/success badges (e.g. "Active", "Always On") — adapts in dark mode
        static let activeStatusBackground = Color(uiColor: .systemGreen).opacity(0.2)
        
        /// Winner/trophy accent (e.g. completed tournament winner) — adapts in dark mode
        static let winnerAccent = Color(uiColor: .systemYellow)
        
        /// Semantic orange for stat cards and data differentiation
        static let statOrange = Color(uiColor: .systemOrange)
        
        /// Semantic yellow for stat cards and data differentiation
        static let statYellow = Color(uiColor: .systemYellow)
        
        /// Semantic gray for data differentiation (e.g. 2nd place)
        static let semanticGray = Color(uiColor: .systemGray)
        
        /// Placement/legend blue (e.g. placement points)
        static let placementAccent = Color(uiColor: .systemBlue)
        
        /// Achievement/legend green (e.g. achievement points)
        static let achievementAccent = Color(uiColor: .systemGreen)
    }
    
    // MARK: - League / Tournament
    
    enum League {
        /// Valid range for total weeks in a tournament
        static let weeksRange = 1...99
        
        /// Valid range for random achievements per week
        static let randomAchievementsPerWeekRange = 0...99
        
        /// Default number of weeks when creating a new league
        static let defaultTotalWeeks = 6
        
        /// Default number of random achievements per week
        static let defaultRandomAchievementsPerWeek = 2
        
        /// Number of rounds per week
        static let roundsPerWeek = 3
        
        /// Default number of players per table (legacy alias: podSize)
        static let podSize = 4

        /// Valid range for players per table when creating a tournament
        static let playersPerTableRange = 2...8

        static let defaultPlayersPerTable = 4
        
        /// Default current week when starting
        static let defaultCurrentWeek = 1
        
        /// Default current round when starting
        static let defaultCurrentRound = 1
        
        /// Default value for achievements on this week
        static let defaultAchievementsOnThisWeek = true

        /// Default: rounds 2–3 group by previous-round placement (client league style).
        static let defaultStandingsBasedSeating = true
    }

    // MARK: - Tournament Rules (Budget Commander defaults)

    enum TournamentRulesDefaults {
        static let entryFeeCents = 1_000
        static let signupBoosterPrize = true
        static let podWinnerBoosterPrize = true
        static let deckBudgetCents = 7_500
        static let pricingSource = DeckPricingSource.lowestOfTCGPlayerOrMoxfield
        static let maxCardPriceCents = 1_000
        static let commanderExcludedFromBudget = true
        static let basicLandsExcludedFromBudget = true
        static let commanderPriceLimitCents: Int? = nil
        static let targetBracket = 2
        static let playstyleNotes = "Keep games friendly and focused. Bracket 2 means one clear strategy per deck — not combo-heavy."

        static let entryFeeDollarsRange = 0...100
        static let deckBudgetDollarsRange = 0...500
        static let cardPriceDollarsRange = 0...100
        static let commanderPriceDollarsRange = 1...500
        static let bracketRange = 1...5
        static let playstyleNotesMaxLength = 200

        static var defaultRules: TournamentRules {
            TournamentRules(
                entryFeeCents: entryFeeCents,
                signupBoosterPrize: signupBoosterPrize,
                podWinnerBoosterPrize: podWinnerBoosterPrize,
                deckBudgetCents: deckBudgetCents,
                pricingSource: pricingSource,
                maxCardPriceCents: maxCardPriceCents,
                commanderExcludedFromBudget: commanderExcludedFromBudget,
                basicLandsExcludedFromBudget: basicLandsExcludedFromBudget,
                commanderPriceLimitCents: commanderPriceLimitCents,
                targetBracket: targetBracket,
                playstyleNotes: playstyleNotes
            )
        }

        static var simpleLeagueRules: TournamentRules {
            TournamentRules(
                entryFeeCents: 0,
                signupBoosterPrize: false,
                podWinnerBoosterPrize: false,
                deckBudgetCents: 0,
                pricingSource: .tcgPlayer,
                maxCardPriceCents: 0,
                commanderExcludedFromBudget: false,
                basicLandsExcludedFromBudget: false,
                commanderPriceLimitCents: nil,
                targetBracket: nil,
                playstyleNotes: ""
            )
        }
    }
    
    // MARK: - Scoring
    
    enum Scoring {
        static let defaultPlacementScale = [4, 3, 2, 1]

        /// Returns placement points for a given place using the default 4-player scale.
        static func placementPoints(forPlace place: Int) -> Int {
            placementPoints(forPlace: place, scale: defaultPlacementScale)
        }

        /// Returns placement points for a given place using a tournament-specific scale.
        static func placementPoints(forPlace place: Int, scale: [Int]) -> Int {
            guard place >= 1, place <= scale.count else { return 0 }
            return scale[place - 1]
        }

        /// Dictionary mapping placement to points (default scale)
        static let placementToPoints: [Int: Int] = [
            1: defaultPlacementScale[0],
            2: defaultPlacementScale[1],
            3: defaultPlacementScale[2],
            4: defaultPlacementScale[3]
        ]
        
        /// Initial placement points for a new player
        static let initialPlacementPoints = 0
        
        /// Initial achievement points for a new player
        static let initialAchievementPoints = 0
        
        /// Initial wins for a new player
        static let initialWins = 0
        
        /// Initial games played for a new player
        static let initialGamesPlayed = 0
    }
    
    // MARK: - App / Settings
    
    enum AppInfo {
        /// Author name shown in Settings (e.g. "Made by …")
        static let authorName = "Jacob Rozell"
    }
    
    // MARK: - Default Achievement

    enum DefaultAchievement {
        /// Name of the default seeded achievement
        static let name = "Table Captain"

        /// Points for the default achievement
        static let points = 1

        /// Whether the default achievement is always on
        static let alwaysOn = false

        /// Default rule description
        static let achievementDescription = "Kept the game moving and helped others"

        /// Default category
        static let category: AchievementCategory = .social

        /// Default icon
        static let iconName = "megaphone.fill"

        /// Default exclusivity
        static let exclusivity: AchievementExclusivity = .onePerPod
    }

    // MARK: - Achievement catalog

    enum Achievement {
        static let nameMaxLength = 80
        static let descriptionMaxLength = 200
        static let pointsRange = 0...99
        static let defaultIconName = "trophy.fill"

        static func pointsTier(for points: Int) -> AchievementPointsTier? {
            AchievementPointsTier.tier(for: points)
        }

        static func sanitizedIconName(_ iconName: String) -> String {
            iconAllowlist.contains(iconName) ? iconName : defaultIconName
        }

        static let iconAllowlistByCategory: [AchievementCategory: [String]] = [
            .combat: ["flame.fill", "bolt.fill", "scope", "burst.fill", "shield.fill", "flag.fill", "target"],
            .deckbuilding: ["rectangle.stack.fill", "square.grid.3x3.fill", "paintpalette.fill", "sparkles", "circle.fill", "square.stack.3d.up.fill"],
            .social: ["person.3.fill", "hand.wave.fill", "heart.fill", "megaphone.fill", "hand.thumbsup.fill", "bubble.left.and.bubble.right.fill"],
            .chaos: ["dice.fill", "questionmark.circle.fill", "wand.and.stars", "tornado", "shuffle"],
            .seasonal: ["leaf.fill", "snowflake", "sun.max.fill", "moon.fill", "calendar"],
            .custom: ["trophy.fill", "star.fill", "medal.fill", "crown.fill", "rosette", "seal.fill"],
        ]

        static var iconAllowlist: [String] {
            Array(Set(iconAllowlistByCategory.values.flatMap { $0 }))
        }

        static func iconDisplayName(_ iconName: String) -> String {
            iconName
                .replacingOccurrences(of: ".fill", with: "")
                .replacingOccurrences(of: ".", with: " ")
                .capitalized
        }
    }
}
