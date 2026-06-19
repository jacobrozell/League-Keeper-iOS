import Foundation
import SwiftData

/// Business logic engine for the Budget League Tracker.
/// Contains pure or nearly pure functions for scoring and state transitions.
/// ViewModels call these functions with SwiftData context and apply results.
enum LeagueEngine {

    /// Outcome of a mid-week attendance update.
    struct AttendanceUpdateResult: Equatable {
        let clearedTables: Bool
        let saved: Bool
    }
    
    // MARK: - Tournament Lifecycle
    
    /// Creates a new tournament with the given settings.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - name: Tournament name
    ///   - totalWeeks: Number of weeks
    ///   - randomPerWeek: Random achievements per week
    ///   - playerIds: IDs of players participating in this tournament
    static func createTournament(
        context: ModelContext,
        name: String,
        totalWeeks: Int,
        randomPerWeek: Int,
        playerIds: [String],
        presentAttendance: Bool = true,
        standingsBasedSeating: Bool = AppConstants.League.defaultStandingsBasedSeating,
        rules: TournamentRules = AppConstants.TournamentRulesDefaults.defaultRules
    ) {
        let clampedWeeks = min(max(totalWeeks, AppConstants.League.weeksRange.lowerBound),
                               AppConstants.League.weeksRange.upperBound)
        let clampedRandom = min(max(randomPerWeek, AppConstants.League.randomAchievementsPerWeekRange.lowerBound),
                                AppConstants.League.randomAchievementsPerWeekRange.upperBound)
        
        // Create the tournament
        let tournament = Tournament(
            name: name,
            totalWeeks: clampedWeeks,
            randomAchievementsPerWeek: clampedRandom,
            rules: rules
        )
        tournament.standingsBasedSeating = standingsBasedSeating
        context.insert(tournament)
        
        // Roll active achievements for week 1
        let achievements = fetchAllAchievements(context: context)
        tournament.activeAchievementIds = rollActiveAchievements(
            achievements: achievements,
            randomPerWeek: clampedRandom
        ).map { $0.id }
        
        // Update league state
        guard let state = fetchLeagueState(context: context) else { return }
        state.activeTournamentId = tournament.id
        state.screen = presentAttendance ? .attendance : .tournaments
        
        // Increment tournamentsPlayed for selected players
        let playerDescriptor = FetchDescriptor<Player>()
        if let allPlayers = try? context.fetch(playerDescriptor) {
            for player in allPlayers where playerIds.contains(player.id) {
                player.tournamentsPlayed += 1
            }
        }
        
        try? context.save()
    }
    
    /// Archives the current tournament (marks as completed).
    /// - Parameter context: The SwiftData model context
    static func archiveTournament(context: ModelContext) {
        guard let tournament = fetchActiveTournament(context: context) else { return }
        
        tournament.status = .completed
        tournament.endDate = Date()
        
        // Clear active tournament reference
        if let state = fetchLeagueState(context: context) {
            state.activeTournamentId = nil
            state.screen = .tournaments
        }
        
        try? context.save()
    }
    
    /// Updates an existing tournament's name and settings.
    struct TournamentEditWarnings: Equatable {
        let messages: [String]
        var requiresConfirmation: Bool { !messages.isEmpty }
    }

    static func tournamentEditWarnings(
        for tournament: Tournament,
        totalWeeks: Int,
        standingsBasedSeating: Bool,
        rules: TournamentRules
    ) -> TournamentEditWarnings {
        var messages: [String] = []
        if tournament.status == .ongoing, totalWeeks < tournament.currentWeek {
            messages.append("This season is on week \(tournament.currentWeek). Shortening total weeks hides later weeks but keeps saved scores.")
        }
        if tournament.status == .ongoing, tournament.standingsBasedSeating != standingsBasedSeating {
            messages.append("Seating rule changes apply to future rounds, not tables already scored.")
        }
        if tournament.status == .ongoing, tournament.rules != rules {
            messages.append("House rule changes mid-season affect how you run future nights — existing scores stay as recorded.")
        }
        return TournamentEditWarnings(messages: messages)
    }

    static func updateTournament(
        context: ModelContext,
        id: String,
        name: String,
        totalWeeks: Int,
        randomPerWeek: Int,
        standingsBasedSeating: Bool,
        rules: TournamentRules
    ) {
        guard let tournament = fetchTournament(context: context, id: id) else { return }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        tournament.name = trimmedName.isEmpty ? tournament.name : trimmedName
        tournament.totalWeeks = min(max(totalWeeks, AppConstants.League.weeksRange.lowerBound),
                                   AppConstants.League.weeksRange.upperBound)
        tournament.randomAchievementsPerWeek = min(max(randomPerWeek, AppConstants.League.randomAchievementsPerWeekRange.lowerBound),
                                                  AppConstants.League.randomAchievementsPerWeekRange.upperBound)
        tournament.standingsBasedSeating = standingsBasedSeating
        tournament.rules = rules
        
        try? context.save()
    }
    
    /// Deletes a tournament and all its GameResults.
    static func deleteTournament(context: ModelContext, id: String) {
        let results = StatsEngine.fetchResultsForTournament(id, context: context)
        for result in results {
            context.delete(result)
        }
        
        if let tournament = fetchTournament(context: context, id: id) {
            context.delete(tournament)
        }
        
        if let state = fetchLeagueState(context: context), state.activeTournamentId == id {
            state.activeTournamentId = nil
            state.screen = .tournaments
        }
        
        try? context.save()
    }
    
    // MARK: - Player Management
    
    /// Adds a new player with the given name.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - name: The player's name (will be trimmed)
    /// - Returns: The created player, or nil if name was empty
    @discardableResult
    static func addPlayer(context: ModelContext, name: String, nameNote: String? = nil) -> Player? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard PlayerNameValidation.validate(name: trimmedName) == nil else { return nil }

        let player = Player(name: trimmedName, nameNote: PlayerDisambiguation.sanitizedNote(nameNote))
        context.insert(player)
        try? context.save()
        return player
    }
    
    /// Removes a player by ID.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - id: The player's ID
    static func removePlayer(context: ModelContext, id: String) {
        let descriptor = FetchDescriptor<Player>()
        if let players = try? context.fetch(descriptor),
           let player = players.first(where: { $0.id == id }) {
            context.delete(player)
            try? context.save()
        }
    }

    /// Updates a player's display name and optional distinguishing note.
    /// - Returns: `nil` on success, or an error message.
    @discardableResult
    static func updatePlayer(
        context: ModelContext,
        id: String,
        name: String,
        nameNote: String?
    ) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let error = PlayerNameValidation.validate(name: trimmed) {
            return error
        }

        let descriptor = FetchDescriptor<Player>()
        guard let players = try? context.fetch(descriptor),
              let player = players.first(where: { $0.id == id }) else {
            return "Player not found."
        }

        player.name = trimmed
        player.nameNote = PlayerDisambiguation.sanitizedNote(nameNote)
        try? context.save()
        return nil
    }

    /// Updates a player's display name.
    /// - Returns: `nil` on success, or an error message.
    @discardableResult
    static func updatePlayerName(context: ModelContext, id: String, name: String) -> String? {
        let descriptor = FetchDescriptor<Player>()
        guard let players = try? context.fetch(descriptor),
              let player = players.first(where: { $0.id == id }) else {
            return "Player not found."
        }
        return updatePlayer(context: context, id: id, name: name, nameNote: player.nameNote)
    }
    
    // MARK: - Attendance
    
    /// Confirms attendance for the current week (first save for the week).
    /// Resets round state and weekly scoring — use `updateAttendance` when attendance was already confirmed.
    @discardableResult
    static func confirmAttendance(
        context: ModelContext,
        presentIds: [String],
        achievementsOnThisWeek: Bool
    ) -> Bool {
        guard let tournament = fetchActiveTournament(context: context) else { return false }
        
        tournament.presentPlayerIds = presentIds
        tournament.achievementsOnThisWeek = achievementsOnThisWeek
        tournament.currentRound = AppConstants.League.defaultCurrentRound

        recordAttendanceSnapshot(
            tournament: tournament,
            week: tournament.currentWeek,
            presentIds: presentIds
        )
        
        // Reset weekly points for all present players
        var weeklyPoints: [String: WeeklyPlayerPoints] = [:]
        for playerId in presentIds {
            weeklyPoints[playerId] = WeeklyPlayerPoints()
        }
        tournament.weeklyPointsByPlayer = weeklyPoints
        
        tournament.podHistorySnapshots = []
        
        // Clear any leftover round data
        tournament.roundPlacements = [:]
        tournament.roundAchievementChecks = []
        tournament.currentRoundPodsPlayerIds = []
        tournament.tableScoringOrders = []
        tournament.confirmedTableIndices = []
        tournament.roundScoringStarted = false
        
        if let state = fetchLeagueState(context: context) {
            state.screen = .tournaments
        }
        
        return PersistenceSave.save(context: context, event: .round)
    }

    /// Updates who's present without resetting round progress or weekly scores.
    /// Clears in-progress table seatings when the present roster changes.
    @discardableResult
    static func updateAttendance(
        context: ModelContext,
        presentIds: [String],
        achievementsOnThisWeek: Bool
    ) -> AttendanceUpdateResult {
        guard let tournament = fetchActiveTournament(context: context) else {
            return AttendanceUpdateResult(clearedTables: false, saved: false)
        }

        guard !tournament.presentPlayerIds.isEmpty else {
            let saved = confirmAttendance(
                context: context,
                presentIds: presentIds,
                achievementsOnThisWeek: achievementsOnThisWeek
            )
            return AttendanceUpdateResult(clearedTables: false, saved: saved)
        }

        let previousPresent = Set(tournament.presentPlayerIds)
        let newPresent = Set(presentIds)
        let attendanceChanged = previousPresent != newPresent
        let hadTables = !tournament.currentRoundPodsPlayerIds.isEmpty

        tournament.presentPlayerIds = presentIds
        tournament.achievementsOnThisWeek = achievementsOnThisWeek

        recordAttendanceSnapshot(
            tournament: tournament,
            week: tournament.currentWeek,
            presentIds: presentIds
        )

        if attendanceChanged, hadTables {
            ScoringEngine.clearTransientRoundState(on: tournament)
            let saved = PersistenceSave.save(context: context, event: .round)
            return AttendanceUpdateResult(clearedTables: true, saved: saved)
        }

        let saved = PersistenceSave.save(context: context, event: .round)
        return AttendanceUpdateResult(clearedTables: false, saved: saved)
    }
    
    /// Adds a new player during attendance (joins league and is marked present).
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - name: The player's name
    /// - Returns: The created player, or nil if name was empty
    @discardableResult
    static func addWeeklyPlayer(context: ModelContext, name: String) -> Player? {
        guard let player = addPlayer(context: context, name: name) else { return nil }
        guard let tournament = fetchActiveTournament(context: context) else { return player }
        
        // Add to present players
        var presentIds = tournament.presentPlayerIds
        presentIds.append(player.id)
        tournament.presentPlayerIds = presentIds
        
        // Add to weekly points
        var weeklyPoints = tournament.weeklyPointsByPlayer
        weeklyPoints[player.id] = WeeklyPlayerPoints()
        tournament.weeklyPointsByPlayer = weeklyPoints
        
        // Increment tournamentsPlayed since they're joining mid-tournament
        player.tournamentsPlayed += 1

        _ = PersistenceSave.save(context: context, event: .round)
        return player
    }
    
    // MARK: - Pod Generation
    
    /// Generates pods for the current round.
    /// - Parameters:
    ///   - players: All players in the league
    ///   - presentPlayerIds: IDs of present players
    ///   - currentRound: The current round number
    ///   - standingsBasedSeating: When true, rounds 2+ group by previous-round finish (1sts at table 1, etc.)
    ///   - previousRoundPlacements: Finish positions from the prior round (playerId -> place 1–4)
    ///   - forceRandom: When true, always shuffle (e.g. host tapped Reshuffle Tables)
    /// - Returns: Array of player groups (pods)
    static func generatePodsForRound(
        players: [Player],
        presentPlayerIds: [String],
        currentRound: Int,
        standingsBasedSeating: Bool = AppConstants.League.defaultStandingsBasedSeating,
        previousRoundPlacements: [String: Int] = [:],
        forceRandom: Bool = false
    ) -> [[Player]] {
        PodEngine.generatePodsForRound(
            players: players,
            presentPlayerIds: presentPlayerIds,
            currentRound: currentRound,
            standingsBasedSeating: standingsBasedSeating,
            previousRoundPlacements: previousRoundPlacements,
            forceRandom: forceRandom
        )
    }

    // MARK: - Auto-Save (Individual Placements/Achievements)
    
    /// Updates a single player's placement for the current round (auto-save).
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - playerId: The player's ID
    ///   - placement: The placement (1-4)
    @discardableResult
    static func updatePlacement(context: ModelContext, playerId: String, placement: Int) -> Bool {
        ScoringEngine.updatePlacement(context: context, playerId: playerId, placement: placement)
    }

    /// Updates a single achievement check for the current round (auto-save).
    /// Enforces one-per-pod exclusivity when checking on.
    @discardableResult
    static func updateAchievementCheck(
        context: ModelContext,
        playerId: String,
        achievementId: String,
        checked: Bool,
        podPlayerIds: [String]? = nil
    ) -> Bool {
        ScoringEngine.updateAchievementCheck(
            context: context,
            playerId: playerId,
            achievementId: achievementId,
            checked: checked,
            podPlayerIds: podPlayerIds
        )
    }

    /// Returns whether a player already earned an achievement earlier in the current week.
    static func playerHasEarnedAchievementThisWeek(
        context: ModelContext,
        tournamentId: String,
        week: Int,
        playerId: String,
        achievementId: String,
        excludingRound: Int? = nil
    ) -> Bool {
        let descriptor = FetchDescriptor<GameResult>()
        guard let results = try? context.fetch(descriptor) else { return false }

        return results.contains { result in
            result.tournamentId == tournamentId
                && result.week == week
                && result.playerId == playerId
                && (excludingRound == nil || result.round != excludingRound)
                && result.achievementIds.contains(achievementId)
        }
    }
    
    /// Finalizes the current round's placements and achievements.
    @discardableResult
    static func finalizeRound(context: ModelContext) -> Bool {
        ScoringEngine.finalizeRound(context: context)
    }

    /// Records pod groupings for the current round (used by tests and legacy pod flows).
    @discardableResult
    static func recordRoundPods(context: ModelContext, pods: [[String]]) -> Bool {
        guard let tournament = fetchActiveTournament(context: context) else { return false }
        tournament.currentRoundPodsPlayerIds = pods
        return PersistenceSave.save(context: context, event: .round)
    }

    /// Clears the current round's placements and achievements without applying them.
    @discardableResult
    static func clearRoundData(context: ModelContext) -> Bool {
        guard let tournament = fetchActiveTournament(context: context) else { return false }

        ScoringEngine.clearTransientRoundState(on: tournament)

        return PersistenceSave.save(context: context, event: .round)
    }

    /// Resets in-progress round scoring state without touching pod history.
    static func clearTransientRoundState(on tournament: Tournament) {
        ScoringEngine.clearTransientRoundState(on: tournament)
    }

    /// Undoes the last saved pod.
    @discardableResult
    static func undoLastPod(context: ModelContext) -> Bool {
        ScoringEngine.undoLastPod(context: context)
    }

    /// Applies edited round data, replacing a snapshot with updated values.
    @discardableResult
    static func applyEditedRound(
        context: ModelContext,
        snapshotIndex: Int? = nil,
        newPlacements: [String: Int],
        newAchievementChecks: Set<String>
    ) -> Bool {
        ScoringEngine.applyEditedRound(
            context: context,
            snapshotIndex: snapshotIndex,
            newPlacements: newPlacements,
            newAchievementChecks: newAchievementChecks
        )
    }

    // MARK: - Round/Week Progression

    /// Advances to the next round or next week (no modal).
    /// Finalizes current round's placements before advancing.
    @discardableResult
    static func nextRound(context: ModelContext) -> Bool {
        guard finalizeRound(context: context) else { return false }

        guard let tournament = fetchActiveTournament(context: context) else { return false }
        guard let state = fetchLeagueState(context: context) else { return false }
        
        if tournament.currentRound < AppConstants.League.roundsPerWeek {
            // Advance to next round
            tournament.currentRound += 1
        } else {
            // End of week - advance to next week or end tournament
            if tournament.isFinalWeek {
                // Archive the tournament; show final standings so user can review before returning to list
                tournament.status = .completed
                tournament.endDate = Date()
                state.screen = .tournamentStandings
            } else {
                tournament.currentWeek += 1
                tournament.currentRound = AppConstants.League.defaultCurrentRound
                tournament.presentPlayerIds = []
                tournament.weeklyPointsByPlayer = [:]
                tournament.podHistorySnapshots = []
                
                // Roll new active achievements
                let achievements = fetchAllAchievements(context: context)
                tournament.activeAchievementIds = rollActiveAchievements(
                    achievements: achievements,
                    randomPerWeek: tournament.randomAchievementsPerWeek
                ).map { $0.id }
                
                state.screen = .attendance
            }
        }

        return PersistenceSave.save(context: context, event: .round)
    }

    /// Closes weekly standings and advances to next week or tournament standings.
    static func closeWeeklyStandings(context: ModelContext) {
        guard let tournament = fetchActiveTournament(context: context) else { return }
        guard let state = fetchLeagueState(context: context) else { return }
        
        if tournament.isFinalWeek {
            tournament.status = .completed
            tournament.endDate = Date()
            state.screen = .tournaments
        } else {
            tournament.currentWeek += 1
            tournament.currentRound = AppConstants.League.defaultCurrentRound
            tournament.presentPlayerIds = []
            tournament.weeklyPointsByPlayer = [:]
            tournament.podHistorySnapshots = []
            
            // Roll new active achievements
            let achievements = fetchAllAchievements(context: context)
            tournament.activeAchievementIds = rollActiveAchievements(
                achievements: achievements,
                randomPerWeek: tournament.randomAchievementsPerWeek
            ).map { $0.id }
            
            state.screen = .attendance
        }
        
        try? context.save()
    }
    
    /// Exits weekly standings back to pods without advancing.
    /// - Parameter context: The SwiftData model context
    static func exitWeeklyStandings(context: ModelContext) {
        guard let state = fetchLeagueState(context: context) else { return }
        state.screen = .tournaments
        _ = PersistenceSave.save(context: context, event: .tournament)
    }
    
    /// Closes tournament standings and returns to tournaments list.
    /// - Parameter context: The SwiftData model context
    static func closeTournamentStandings(context: ModelContext) {
        guard let state = fetchLeagueState(context: context) else { return }
        state.activeTournamentId = nil
        state.screen = .tournaments
        try? context.save()
    }
    
    // MARK: - Achievement Management
    
    /// Rolls active achievements for a week.
    /// - Parameters:
    ///   - achievements: All available achievements
    ///   - randomPerWeek: Number of random achievements to include
    /// - Returns: Array of active achievements (always-on + random sample)
    static func rollActiveAchievements(
        achievements: [Achievement],
        randomPerWeek: Int
    ) -> [Achievement] {
        let alwaysOn = achievements.filter { $0.alwaysOn }
        let notAlwaysOn = achievements.filter { !$0.alwaysOn }
        
        let randomCount = min(randomPerWeek, notAlwaysOn.count)
        let randomSample = Array(notAlwaysOn.shuffled().prefix(randomCount))
        
        return alwaysOn + randomSample
    }
    
    /// Adds a new achievement.
    @discardableResult
    static func addAchievement(
        context: ModelContext,
        name: String,
        points: Int,
        alwaysOn: Bool,
        achievementDescription: String? = nil,
        category: AchievementCategory = .custom,
        iconName: String = AppConstants.Achievement.defaultIconName,
        exclusivity: AchievementExclusivity = .unlimited
    ) -> Achievement? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        let clampedPoints = min(
            max(points, AppConstants.Achievement.pointsRange.lowerBound),
            AppConstants.Achievement.pointsRange.upperBound
        )
        let trimmedDescription = achievementDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = (trimmedDescription?.isEmpty == false) ? trimmedDescription : nil
        let truncatedDescription = normalizedDescription.map {
            String($0.prefix(AppConstants.Achievement.descriptionMaxLength))
        }
        let truncatedName = String(trimmedName.prefix(AppConstants.Achievement.nameMaxLength))

        let achievement = Achievement(
            name: truncatedName,
            points: clampedPoints,
            alwaysOn: alwaysOn,
            achievementDescription: truncatedDescription,
            category: category,
            iconName: AppConstants.Achievement.sanitizedIconName(iconName),
            exclusivity: exclusivity
        )
        context.insert(achievement)
        try? context.save()
        return achievement
    }

    /// Updates an existing achievement.
    @discardableResult
    static func updateAchievement(
        context: ModelContext,
        id: String,
        name: String,
        points: Int,
        alwaysOn: Bool,
        achievementDescription: String?,
        category: AchievementCategory,
        iconName: String,
        exclusivity: AchievementExclusivity
    ) -> Bool {
        guard let achievement = fetchAchievement(context: context, id: id) else { return false }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return false }

        let clampedPoints = min(
            max(points, AppConstants.Achievement.pointsRange.lowerBound),
            AppConstants.Achievement.pointsRange.upperBound
        )
        let trimmedDescription = achievementDescription?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = (trimmedDescription?.isEmpty == false) ? trimmedDescription : nil

        achievement.name = String(trimmedName.prefix(AppConstants.Achievement.nameMaxLength))
        achievement.points = clampedPoints
        achievement.alwaysOn = alwaysOn
        achievement.achievementDescription = normalizedDescription.map {
            String($0.prefix(AppConstants.Achievement.descriptionMaxLength))
        }
        achievement.category = category
        achievement.iconName = AppConstants.Achievement.sanitizedIconName(iconName)
        achievement.exclusivity = exclusivity

        try? context.save()
        return true
    }

    /// Fetches a single achievement by ID.
    static func fetchAchievement(context: ModelContext, id: String) -> Achievement? {
        let descriptor = FetchDescriptor<Achievement>()
        let achievements = (try? context.fetch(descriptor)) ?? []
        return achievements.first { $0.id == id }
    }
    
    /// Removes an achievement by ID.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - id: The achievement's ID
    static func removeAchievement(context: ModelContext, id: String) {
        let descriptor = FetchDescriptor<Achievement>()
        if let achievements = try? context.fetch(descriptor),
           let achievement = achievements.first(where: { $0.id == id }) {
            context.delete(achievement)
            try? context.save()
        }
    }
    
    /// Updates an achievement's alwaysOn status.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - id: The achievement's ID
    ///   - alwaysOn: New alwaysOn value
    static func setAchievementAlwaysOn(context: ModelContext, id: String, alwaysOn: Bool) {
        let descriptor = FetchDescriptor<Achievement>()
        if let achievements = try? context.fetch(descriptor),
           let achievement = achievements.first(where: { $0.id == id }) {
            achievement.alwaysOn = alwaysOn
            try? context.save()
        }
    }
    
    // MARK: - Navigation
    
    /// Sets the current screen.
    /// - Parameters:
    ///   - context: The SwiftData model context
    ///   - screen: The screen to navigate to
    static func setScreen(context: ModelContext, screen: Screen) {
        guard let state = fetchLeagueState(context: context) else { return }
        state.screen = screen
        try? context.save()
    }
    
    // MARK: - State Validation
    
    /// Validates and sanitizes the league state to ensure consistency.
    /// Call this on app launch to fix any corrupted or inconsistent state.
    /// - Parameter context: The SwiftData model context
    static func validateAndSanitizeState(context: ModelContext) {
        guard let state = fetchLeagueState(context: context) else { return }
        
        var needsSave = false
        
        // Check if we have an active tournament
        if let tournamentId = state.activeTournamentId {
            // Verify the tournament exists
            let descriptor = FetchDescriptor<Tournament>()
            let allTournaments = (try? context.fetch(descriptor)) ?? []
            let tournament = allTournaments.first { $0.id == tournamentId }
            
            if tournament == nil {
                // Tournament doesn't exist, clear reference
                state.activeTournamentId = nil
                state.screen = .tournaments
                needsSave = true
            } else if tournament?.status == .completed {
                // Tournament is completed, clear reference
                state.activeTournamentId = nil
                state.screen = .tournaments
                needsSave = true
            }
        } else {
            // No active tournament - only allow pre-tournament screens
            let validScreens: [Screen] = [.tournaments, .newTournament]
            if !validScreens.contains(state.screen) {
                state.screen = .tournaments
                needsSave = true
            }
        }

        // Normalize legacy persisted screen values
        let normalized = Screen.migrated(from: state.currentScreen)
        if normalized.rawValue != state.currentScreen {
            state.screen = normalized
            needsSave = true
        }
        
        if needsSave {
            _ = PersistenceSave.save(context: context, event: .tournament)
        }
    }
    
    // MARK: - Helpers

    /// Fetches all achievements from the context.
    static func fetchAllAchievements(context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>()
        return (try? context.fetch(descriptor)) ?? []
    }
    
    /// Fetches the league state.
    static func fetchLeagueState(context: ModelContext) -> LeagueState? {
        let descriptor = FetchDescriptor<LeagueState>()
        return (try? context.fetch(descriptor))?.first
    }
    
    /// Fetches the active tournament.
    static func fetchActiveTournament(context: ModelContext) -> Tournament? {
        guard let state = fetchLeagueState(context: context),
              let tournamentId = state.activeTournamentId else { return nil }
        
        let descriptor = FetchDescriptor<Tournament>()
        let allTournaments = (try? context.fetch(descriptor)) ?? []
        return allTournaments.first { $0.id == tournamentId }
    }
    
    /// Fetches a tournament by ID.
    static func fetchTournament(context: ModelContext, id: String) -> Tournament? {
        let descriptor = FetchDescriptor<Tournament>()
        let allTournaments = (try? context.fetch(descriptor)) ?? []
        return allTournaments.first { $0.id == id }
    }

    /// Records or updates attendance for a tournament week.
    static func recordAttendanceSnapshot(
        tournament: Tournament,
        week: Int,
        presentIds: [String]
    ) {
        var history = tournament.attendanceHistory
        let snapshot = WeekAttendanceSnapshot(
            week: week,
            presentPlayerIds: presentIds,
            confirmedAt: Date()
        )
        if let index = history.firstIndex(where: { $0.week == week }) {
            history[index] = snapshot
        } else {
            history.append(snapshot)
        }
        tournament.attendanceHistory = history.sorted { $0.week < $1.week }
    }
}
