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
        
        /// Number of players per pod
        static let podSize = 4
        
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
        static let playstyleNotes = "Keep it casual and fun — aim for Bracket 2."

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
    }
    
    // MARK: - Scoring
    
    enum Scoring {
        /// Returns placement points for a given place (1st through 4th)
        /// - Parameter place: The finishing place (1-4)
        /// - Returns: Points awarded (1st=4, 2nd=3, 3rd=2, 4th=1)
        static func placementPoints(forPlace place: Int) -> Int {
            switch place {
            case 1: return 4
            case 2: return 3
            case 3: return 2
            case 4: return 1
            default: return 0
            }
        }
        
        /// Dictionary mapping placement to points
        static let placementToPoints: [Int: Int] = [
            1: 4,
            2: 3,
            3: 2,
            4: 1
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
        static let name = "First Blood"

        /// Points for the default achievement
        static let points = 1

        /// Whether the default achievement is always on
        static let alwaysOn = false

        /// Default rule description
        static let achievementDescription = "First player to eliminate another player"

        /// Default category
        static let category: AchievementCategory = .combat

        /// Default icon
        static let iconName = "flame.fill"

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
