import Foundation
import SwiftData

/// Represents the global app state.
/// This is a singleton model - only one instance should exist.
/// Simplified to only track navigation and active tournament reference.
@Model
final class LeagueState {
    /// ID of the currently active tournament (nil if no active tournament)
    var activeTournamentId: String?
    
    /// Current screen for navigation state restoration
    var currentScreen: String
    
    // MARK: - Initialization
    
    /// Creates a new LeagueState with default values.
    init(
        activeTournamentId: String? = nil,
        currentScreen: String = Screen.tournaments.rawValue
    ) {
        self.activeTournamentId = activeTournamentId
        self.currentScreen = currentScreen
    }
    
    // MARK: - Screen Convenience
    
    /// Returns the current screen as a Screen enum value
    var screen: Screen {
        get {
            Screen(rawValue: currentScreen) ?? .tournaments
        }
        set {
            currentScreen = newValue.rawValue
        }
    }
    
    /// Whether there is an active tournament
    var hasActiveTournament: Bool {
        activeTournamentId != nil
    }
}

// MARK: - Supporting Types

/// Tracks a player's points for the current week
struct WeeklyPlayerPoints: Codable, Equatable {
    var placementPoints: Int
    var achievementPoints: Int
    
    var total: Int {
        placementPoints + achievementPoints
    }
    
    init(placementPoints: Int = 0, achievementPoints: Int = 0) {
        self.placementPoints = placementPoints
        self.achievementPoints = achievementPoints
    }
}

/// Snapshot of a saved pod for undo functionality
struct PodSnapshot: Codable, Equatable {
    /// Tournament week when this round was saved
    var week: Int
    /// Round number within the week when saved
    var round: Int

    /// Player IDs in this pod
    var playerIds: [String]
    
    /// Placement for each player (playerId -> place 1-4)
    var placements: [String: Int]
    
    /// Achievement checks (array of (playerId, achievementId) tuples)
    var achievementChecks: [AchievementCheck]
    
    /// Delta applied to each player's cumulative stats
    var playerDeltas: [String: PlayerDelta]
    
    /// Delta applied to each player's weekly points
    var weeklyDeltas: [String: WeeklyPlayerPoints]

    init(
        week: Int = 1,
        round: Int = 1,
        playerIds: [String],
        placements: [String: Int],
        achievementChecks: [AchievementCheck],
        playerDeltas: [String: PlayerDelta],
        weeklyDeltas: [String: WeeklyPlayerPoints]
    ) {
        self.week = week
        self.round = round
        self.playerIds = playerIds
        self.placements = placements
        self.achievementChecks = achievementChecks
        self.playerDeltas = playerDeltas
        self.weeklyDeltas = weeklyDeltas
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        week = try container.decodeIfPresent(Int.self, forKey: .week) ?? 1
        round = try container.decodeIfPresent(Int.self, forKey: .round) ?? 1
        playerIds = try container.decode([String].self, forKey: .playerIds)
        placements = try container.decode([String: Int].self, forKey: .placements)
        achievementChecks = try container.decode([AchievementCheck].self, forKey: .achievementChecks)
        playerDeltas = try container.decode([String: PlayerDelta].self, forKey: .playerDeltas)
        weeklyDeltas = try container.decode([String: WeeklyPlayerPoints].self, forKey: .weeklyDeltas)
    }

    private enum CodingKeys: String, CodingKey {
        case week, round, playerIds, placements, achievementChecks, playerDeltas, weeklyDeltas
    }
}

/// Represents a checked achievement for a player
struct AchievementCheck: Codable, Equatable {
    var playerId: String
    var achievementId: String
    var points: Int
}

/// Delta applied to a player's cumulative stats (for undo)
struct PlayerDelta: Codable, Equatable {
    var placementPoints: Int
    var achievementPoints: Int
    var wins: Int
    var gamesPlayed: Int
}

/// Attendance snapshot for a single tournament week.
struct WeekAttendanceSnapshot: Codable, Equatable {
    var week: Int
    var presentPlayerIds: [String]
    var confirmedAt: Date
}
