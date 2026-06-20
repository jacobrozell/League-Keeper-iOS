import Foundation
import SwiftData

/// Status of a tournament
enum TournamentStatus: String, Codable {
    case ongoing    // Tournament in progress
    case completed  // Tournament finished
}

/// Represents a tournament/league season.
/// Conforms to Identifiable for sheet(item:) presentation.
/// Stores tournament metadata and transient weekly state during active play.
@Model
final class Tournament: Identifiable {
    // MARK: - Tournament Metadata
    
    /// Unique identifier for the tournament
    var id: String
    
    /// Display name for the tournament (e.g., "Spring 2026 League")
    var name: String
    
    /// Total number of weeks in the tournament
    var totalWeeks: Int
    
    /// Number of random achievements to roll each week
    var randomAchievementsPerWeek: Int
    
    /// When the tournament was started
    var startDate: Date
    
    /// When the tournament was completed (nil if ongoing)
    var endDate: Date?
    
    /// Raw status value for SwiftData storage
    var statusRaw: String
    
    // MARK: - Weekly State (transient, for active tournaments)
    
    /// Current week number (1-based)
    var currentWeek: Int
    
    /// Current round within the week (1-3)
    var currentRound: Int
    
    /// Whether achievements count for the current week
    var achievementsOnThisWeek: Bool
    
    /// JSON-encoded array of present player IDs for the current week
    var presentPlayerIdsData: Data?
    
    /// JSON-encoded dictionary of player ID to weekly points [String: WeeklyPlayerPoints]
    var weeklyPointsJSON: Data?
    
    /// JSON-encoded array of active achievement IDs for the current week
    var activeAchievementIdsData: Data?
    
    /// JSON-encoded array of weekly attendance snapshots
    var attendanceHistoryData: Data?

    /// JSON-encoded array of pod history snapshots for undo functionality
    var podHistoryData: Data?
    
    /// JSON-encoded dictionary of current round placements (playerId -> place 1-4)
    var roundPlacementsData: Data?

    /// JSON-encoded nested array of player IDs for the current round's pods
    var currentRoundPodsPlayerIdsData: Data?
    
    /// JSON-encoded set of current round achievement checks ("playerId:achievementId")
    var roundAchievementChecksData: Data?

    /// JSON-encoded indices of tables the host has confirmed for the current round
    var confirmedTableIndicesData: Data?

    /// JSON-encoded player ID order per table for drag-to-rank scoring
    var tableScoringOrdersData: Data?

    /// Whether the host has started scoring tables for the current round
    var roundScoringStarted: Bool = false

    /// When true, rounds 2+ seat players by previous-round finish (1sts at table 1, etc.). Round 1 is always random.
    var standingsBasedSeating: Bool = true

    /// JSON-encoded deck, prize, and playstyle rules for this tournament.
    var rulesData: Data?

    /// Optional preset identifier for display (e.g. simpleLeague, budgetCommander).
    var leaguePresetRaw: String?

    /// Number of players seated at each table for this tournament.
    var playersPerTable: Int = AppConstants.League.defaultPlayersPerTable

    /// JSON-encoded placement point scale (index 0 = 1st place, etc.).
    var placementPointsData: Data?
    
    // MARK: - Initialization
    
    /// Creates a new tournament with the given settings.
    init(
        id: String = UUID().uuidString,
        name: String,
        totalWeeks: Int = AppConstants.League.defaultTotalWeeks,
        randomAchievementsPerWeek: Int = AppConstants.League.defaultRandomAchievementsPerWeek,
        startDate: Date = Date(),
        endDate: Date? = nil,
        status: TournamentStatus = .ongoing,
        currentWeek: Int = AppConstants.League.defaultCurrentWeek,
        currentRound: Int = AppConstants.League.defaultCurrentRound,
        achievementsOnThisWeek: Bool = AppConstants.League.defaultAchievementsOnThisWeek,
        rules: TournamentRules = AppConstants.TournamentRulesDefaults.simpleLeagueRules,
        leaguePreset: LeaguePreset = .simpleLeague,
        playersPerTable: Int = AppConstants.League.defaultPlayersPerTable,
        placementPointsScale: [Int] = AppConstants.Scoring.defaultPlacementScale
    ) {
        self.id = id
        self.name = name
        self.totalWeeks = totalWeeks
        self.randomAchievementsPerWeek = randomAchievementsPerWeek
        self.startDate = startDate
        self.endDate = endDate
        self.statusRaw = status.rawValue
        self.currentWeek = currentWeek
        self.currentRound = currentRound
        self.achievementsOnThisWeek = achievementsOnThisWeek
        self.rules = rules
        self.leaguePresetRaw = leaguePreset.rawValue
        self.playersPerTable = min(
            max(playersPerTable, AppConstants.League.playersPerTableRange.lowerBound),
            AppConstants.League.playersPerTableRange.upperBound
        )
        self.placementPointsScale = placementPointsScale
    }
    
    // MARK: - Status Convenience
    
    /// Returns the tournament status as a TournamentStatus enum value
    var status: TournamentStatus {
        get {
            TournamentStatus(rawValue: statusRaw) ?? .ongoing
        }
        set {
            statusRaw = newValue.rawValue
        }
    }
    
    // MARK: - Present Players
    
    /// Decodes and returns the list of present player IDs
    var presentPlayerIds: [String] {
        get {
            guard let data = presentPlayerIdsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            presentPlayerIdsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Weekly Points
    
    /// Decodes and returns the weekly points dictionary
    var weeklyPointsByPlayer: [String: WeeklyPlayerPoints] {
        get {
            guard let data = weeklyPointsJSON else { return [:] }
            return (try? JSONDecoder().decode([String: WeeklyPlayerPoints].self, from: data)) ?? [:]
        }
        set {
            weeklyPointsJSON = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Active Achievements
    
    /// Decodes and returns the list of active achievement IDs for this week
    var activeAchievementIds: [String] {
        get {
            guard let data = activeAchievementIdsData else { return [] }
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            activeAchievementIdsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Attendance History

    /// Decodes and returns weekly attendance snapshots
    var attendanceHistory: [WeekAttendanceSnapshot] {
        get {
            guard let data = attendanceHistoryData else { return [] }
            return (try? JSONDecoder().decode([WeekAttendanceSnapshot].self, from: data)) ?? []
        }
        set {
            attendanceHistoryData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Pod History
    
    /// Decodes and returns the pod history snapshots for undo
    var podHistorySnapshots: [PodSnapshot] {
        get {
            guard let data = podHistoryData else { return [] }
            return (try? JSONDecoder().decode([PodSnapshot].self, from: data)) ?? []
        }
        set {
            podHistoryData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Current Round Data (for auto-save)
    
    /// Decodes and returns the current round placements (playerId -> place)
    var roundPlacements: [String: Int] {
        get {
            guard let data = roundPlacementsData else { return [:] }
            return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        }
        set {
            roundPlacementsData = try? JSONEncoder().encode(newValue)
        }
    }

    /// Player IDs grouped into pods for the current round.
    var currentRoundPodsPlayerIds: [[String]] {
        get {
            guard let data = currentRoundPodsPlayerIdsData else { return [] }
            return (try? JSONDecoder().decode([[String]].self, from: data)) ?? []
        }
        set {
            currentRoundPodsPlayerIdsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    /// Decodes and returns the current round achievement checks
    var roundAchievementChecks: Set<String> {
        get {
            guard let data = roundAchievementChecksData else { return [] }
            return (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
        }
        set {
            roundAchievementChecksData = try? JSONEncoder().encode(newValue)
        }
    }

    /// Table indices confirmed by the host for the current round
    var confirmedTableIndices: Set<Int> {
        get {
            guard let data = confirmedTableIndicesData else { return [] }
            return (try? JSONDecoder().decode(Set<Int>.self, from: data)) ?? []
        }
        set {
            confirmedTableIndicesData = try? JSONEncoder().encode(newValue)
        }
    }

    /// Player IDs in finish order for each table (index aligns with `currentRoundPodsPlayerIds`)
    var tableScoringOrders: [[String]] {
        get {
            guard let data = tableScoringOrdersData else { return [] }
            return (try? JSONDecoder().decode([[String]].self, from: data)) ?? []
        }
        set {
            tableScoringOrdersData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Tournament Rules

    /// Deck, prize, and playstyle rules. Falls back to simple league defaults when unset.
    var rules: TournamentRules {
        get {
            guard let data = rulesData else { return AppConstants.TournamentRulesDefaults.simpleLeagueRules }
            return (try? JSONDecoder().decode(TournamentRules.self, from: data))
                ?? AppConstants.TournamentRulesDefaults.simpleLeagueRules
        }
        set {
            rulesData = try? JSONEncoder().encode(newValue)
        }
    }

    /// League preset used when creating this tournament (optional for legacy records).
    var leaguePreset: LeaguePreset? {
        get {
            guard let leaguePresetRaw else { return nil }
            return LeaguePreset(rawValue: leaguePresetRaw)
        }
        set {
            leaguePresetRaw = newValue?.rawValue
        }
    }

    /// Placement points awarded by finish position for this tournament.
    var placementPointsScale: [Int] {
        get {
            guard let data = placementPointsData else { return AppConstants.Scoring.defaultPlacementScale }
            return (try? JSONDecoder().decode([Int].self, from: data))
                ?? AppConstants.Scoring.defaultPlacementScale
        }
        set {
            placementPointsData = try? JSONEncoder().encode(newValue)
        }
    }

    /// Effective table size for seating and scoring (clamped to valid range).
    var effectivePlayersPerTable: Int {
        min(
            max(playersPerTable, AppConstants.League.playersPerTableRange.lowerBound),
            AppConstants.League.playersPerTableRange.upperBound
        )
    }

    // MARK: - Computed Properties
    
    /// Whether this is the final week
    var isFinalWeek: Bool {
        currentWeek >= totalWeeks
    }
    
    /// Formatted date range string
    var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let start = formatter.string(from: startDate)
        if let end = endDate {
            return "\(start) - \(formatter.string(from: end))"
        } else {
            return "Started \(start)"
        }
    }
}
