import Foundation
import SwiftData

/// Statistics computation engine for the Budget League Tracker.
/// Provides all-time and per-tournament statistics calculations.
enum StatsEngine {
    
    // MARK: - All-Time Stats
    
    /// Calculates win rate for a player (wins / games played).
    /// - Parameter player: The player
    /// - Returns: Win rate as a decimal (0.0 to 1.0), or 0 if no games played
    static func winRate(for player: Player) -> Double {
        guard player.gamesPlayed > 0 else { return 0 }
        return Double(player.wins) / Double(player.gamesPlayed)
    }
    
    /// Calculates average placement for a player from GameResults.
    /// - Parameters:
    ///   - playerId: The player's ID
    ///   - results: GameResult records to analyze
    /// - Returns: Average placement (1.0 to 4.0), or 0 if no results
    static func averagePlacement(playerId: String, results: [GameResult]) -> Double {
        let playerResults = results.filter { $0.playerId == playerId }
        guard !playerResults.isEmpty else { return 0 }
        
        let totalPlacement = playerResults.reduce(0) { $0 + $1.placement }
        return Double(totalPlacement) / Double(playerResults.count)
    }
    
    /// Calculates placement distribution for a player.
    /// - Parameters:
    ///   - playerId: The player's ID
    ///   - results: GameResult records to analyze
    /// - Returns: Dictionary mapping placement (1-4) to count
    static func placementDistribution(playerId: String, results: [GameResult]) -> [Int: Int] {
        let playerResults = results.filter { $0.playerId == playerId }
        var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]
        
        for result in playerResults {
            distribution[result.placement, default: 0] += 1
        }
        
        return distribution
    }
    
    /// Calculates points per game for a player.
    /// - Parameter player: The player
    /// - Returns: Average points per game, or 0 if no games played
    static func pointsPerGame(for player: Player) -> Double {
        guard player.gamesPlayed > 0 else { return 0 }
        return Double(player.totalPoints) / Double(player.gamesPlayed)
    }
    
    // MARK: - Per-Tournament Stats
    
    /// Calculates stats for a player within a specific tournament.
    /// - Parameters:
    ///   - playerId: The player's ID
    ///   - tournamentId: The tournament's ID
    ///   - results: All GameResult records
    /// - Returns: Tournament-specific stats
    static func tournamentStats(
        playerId: String,
        tournamentId: String,
        results: [GameResult]
    ) -> TournamentPlayerStats {
        let tournamentResults = results.filter {
            $0.playerId == playerId && $0.tournamentId == tournamentId
        }
        
        let gamesPlayed = tournamentResults.count
        let wins = tournamentResults.filter { $0.isWin }.count
        let totalPoints = tournamentResults.reduce(0) { $0 + $1.totalPoints }
        let placementPoints = tournamentResults.reduce(0) { $0 + $1.placementPoints }
        let achievementPoints = tournamentResults.reduce(0) { $0 + $1.achievementPoints }
        
        var distribution: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0]
        for result in tournamentResults {
            distribution[result.placement, default: 0] += 1
        }
        
        let avgPlacement = gamesPlayed > 0 
            ? Double(tournamentResults.reduce(0) { $0 + $1.placement }) / Double(gamesPlayed)
            : 0
        
        return TournamentPlayerStats(
            gamesPlayed: gamesPlayed,
            wins: wins,
            totalPoints: totalPoints,
            placementPoints: placementPoints,
            achievementPoints: achievementPoints,
            placementDistribution: distribution,
            averagePlacement: avgPlacement,
            winRate: gamesPlayed > 0 ? Double(wins) / Double(gamesPlayed) : 0
        )
    }
    
    // MARK: - Head-to-Head Stats
    
    /// Calculates head-to-head record between two players.
    /// A "win" is when player1 places higher than player2 in the same pod.
    /// - Parameters:
    ///   - player1Id: First player's ID
    ///   - player2Id: Second player's ID
    ///   - results: All GameResult records
    /// - Returns: Head-to-head record
    static func headToHeadRecord(
        player1Id: String,
        player2Id: String,
        results: [GameResult]
    ) -> HeadToHeadRecord {
        // Group results by podId
        var podResults: [String: [GameResult]] = [:]
        for result in results {
            podResults[result.podId, default: []].append(result)
        }
        
        var player1Wins = 0
        var player2Wins = 0
        var ties = 0
        
        for (_, podResultsList) in podResults {
            let p1Result = podResultsList.first { $0.playerId == player1Id }
            let p2Result = podResultsList.first { $0.playerId == player2Id }
            
            // Both players must have been in this pod
            guard let p1 = p1Result, let p2 = p2Result else { continue }
            
            if p1.placement < p2.placement {
                player1Wins += 1
            } else if p2.placement < p1.placement {
                player2Wins += 1
            } else {
                ties += 1
            }
        }
        
        return HeadToHeadRecord(
            player1Wins: player1Wins,
            player2Wins: player2Wins,
            ties: ties
        )
    }
    
    // MARK: - Tournament Summary
    
    /// Generates a summary for a tournament.
    /// - Parameters:
    ///   - tournamentId: The tournament's ID
    ///   - results: All GameResult records
    ///   - players: All players
    /// - Returns: Tournament summary
    static func tournamentSummary(
        tournamentId: String,
        results: [GameResult],
        players: [Player]
    ) -> TournamentSummary {
        let tournamentResults = results.filter { $0.tournamentId == tournamentId }
        
        // Get unique player IDs from results
        let participantIds = Set(tournamentResults.map { $0.playerId })
        let participantCount = participantIds.count
        
        // Calculate total games (unique podIds)
        let uniquePodIds = Set(tournamentResults.map { $0.podId })
        let totalGames = uniquePodIds.count
        
        // Find winner (highest total points)
        var pointsByPlayer: [String: Int] = [:]
        for result in tournamentResults {
            pointsByPlayer[result.playerId, default: 0] += result.totalPoints
        }
        
        let winnerId = pointsByPlayer.max(by: { $0.value < $1.value })?.key
        let winnerName = players.first { $0.id == winnerId }?.name
        let winnerPoints = winnerId != nil ? pointsByPlayer[winnerId!] ?? 0 : 0
        
        // Calculate standings
        let standings = pointsByPlayer
            .map { (playerId: $0.key, points: $0.value) }
            .sorted { $0.points > $1.points }
            .compactMap { standing -> (player: Player, points: Int)? in
                guard let player = players.first(where: { $0.id == standing.playerId }) else { return nil }
                return (player: player, points: standing.points)
            }
        
        return TournamentSummary(
            participantCount: participantCount,
            totalGames: totalGames,
            winnerName: winnerName,
            winnerPoints: winnerPoints,
            standings: standings
        )
    }
    
    // MARK: - Fetch Helpers
    
    /// Fetches all GameResults for a player.
    static func fetchResultsForPlayer(_ playerId: String, context: ModelContext) -> [GameResult] {
        let descriptor = FetchDescriptor<GameResult>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let allResults = (try? context.fetch(descriptor)) ?? []
        return allResults.filter { $0.playerId == playerId }
    }
    
    /// Fetches all GameResults for a tournament.
    static func fetchResultsForTournament(_ tournamentId: String, context: ModelContext) -> [GameResult] {
        let descriptor = FetchDescriptor<GameResult>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let allResults = (try? context.fetch(descriptor)) ?? []
        return allResults.filter { $0.tournamentId == tournamentId }
    }
    
    /// Fetches all GameResults.
    static func fetchAllResults(context: ModelContext) -> [GameResult] {
        let descriptor = FetchDescriptor<GameResult>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Fetches all tournaments.
    static func fetchAllTournaments(context: ModelContext) -> [Tournament] {
        let descriptor = FetchDescriptor<Tournament>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// Recent round summaries for a player, newest first.
    static func recentRoundSummaries(
        playerId: String,
        results: [GameResult],
        tournaments: [Tournament],
        limit: Int = 20
    ) -> [PlayerRoundSummary] {
        let tournamentNames = Dictionary(uniqueKeysWithValues: tournaments.map { ($0.id, $0.name) })
        return results
            .filter { $0.playerId == playerId }
            .sorted {
                if $0.week != $1.week { return $0.week > $1.week }
                if $0.round != $1.round { return $0.round > $1.round }
                return $0.timestamp > $1.timestamp
            }
            .prefix(limit)
            .map { result in
                PlayerRoundSummary(
                    id: result.id,
                    tournamentId: result.tournamentId,
                    tournamentName: tournamentNames[result.tournamentId] ?? "Tournament",
                    week: result.week,
                    round: result.round,
                    placement: result.placement,
                    totalPoints: result.totalPoints,
                    achievementCount: result.achievementIds.count,
                    timestamp: result.timestamp,
                    isWin: result.isWin,
                    podId: result.podId
                )
            }
    }

    /// Per-tournament attendance for a player.
    static func attendanceSummaries(
        playerId: String,
        tournaments: [Tournament],
        results: [GameResult]
    ) -> [PlayerAttendanceSummary] {
        tournaments.compactMap { tournament in
            attendanceSummary(
                playerId: playerId,
                tournament: tournament,
                results: results
            )
        }
        .filter { $0.weeksTotal > 0 }
        .sorted { $0.tournamentName.localizedCaseInsensitiveCompare($1.tournamentName) == .orderedAscending }
    }

    private static func attendanceSummary(
        playerId: String,
        tournament: Tournament,
        results: [GameResult]
    ) -> PlayerAttendanceSummary? {
        let history = tournament.attendanceHistory
        if !history.isEmpty {
            let weeksTotal = history.count
            let weeksPresent = history.filter { $0.presentPlayerIds.contains(playerId) }.count
            return PlayerAttendanceSummary(
                tournamentId: tournament.id,
                tournamentName: tournament.name,
                weeksPresent: weeksPresent,
                weeksTotal: weeksTotal
            )
        }

        let playerResults = results.filter {
            $0.playerId == playerId && $0.tournamentId == tournament.id
        }
        guard !playerResults.isEmpty else { return nil }

        let weeksPlayed = Set(playerResults.map(\.week)).count
        return PlayerAttendanceSummary(
            tournamentId: tournament.id,
            tournamentName: tournament.name,
            weeksPresent: weeksPlayed,
            weeksTotal: weeksPlayed
        )
    }

    /// League rank by total points (1 = highest).
    static func leagueRanks(players: [Player]) -> [String: Int] {
        let sorted = players.sorted {
            if $0.totalPoints != $1.totalPoints { return $0.totalPoints > $1.totalPoints }
            return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        var ranks: [String: Int] = [:]
        for (index, player) in sorted.enumerated() {
            ranks[player.id] = index + 1
        }
        return ranks
    }

    /// Recent placements for form dots, newest on the right.
    static func recentPlacements(
        playerId: String,
        results: [GameResult],
        limit: Int = 8
    ) -> [Int] {
        let placements = results
            .filter { $0.playerId == playerId }
            .sorted {
                if $0.week != $1.week { return $0.week < $1.week }
                if $0.round != $1.round { return $0.round < $1.round }
                return $0.timestamp < $1.timestamp
            }
            .map(\.placement)
        return Array(placements.suffix(limit))
    }

    /// Cumulative points per game for sparklines.
    static func sparklinePoints(
        playerId: String,
        results: [GameResult],
        limit: Int = 8
    ) -> [Double] {
        let sorted = results
            .filter { $0.playerId == playerId }
            .sorted {
                if $0.week != $1.week { return $0.week < $1.week }
                if $0.round != $1.round { return $0.round < $1.round }
                return $0.timestamp < $1.timestamp
            }
        var cumulative = 0.0
        let values = sorted.map { result -> Double in
            cumulative += Double(result.totalPoints)
            return cumulative
        }
        return Array(values.suffix(limit))
    }

    /// Last played date for a player.
    static func lastPlayedDate(playerId: String, results: [GameResult]) -> Date? {
        results
            .filter { $0.playerId == playerId }
            .map(\.timestamp)
            .max()
    }

    /// Full round detail for sheet presentation.
    static func roundDetail(
        resultId: String,
        playerId: String,
        results: [GameResult],
        players: [Player],
        achievements: [Achievement]
    ) -> PlayerRoundDetail? {
        guard let result = results.first(where: { $0.id == resultId && $0.playerId == playerId }) else {
            return nil
        }

        let playerNames = PlayerDisambiguation.displayNames(for: players)
        let achievementNames = Dictionary(uniqueKeysWithValues: achievements.map { ($0.id, $0.name) })
        let tournamentName = "Tournament"

        let podResults = results
            .filter { $0.podId == result.podId }
            .sorted { $0.placement < $1.placement }

        let podmates = podResults.map { podResult in
            PodmateResult(
                playerName: playerNames[podResult.playerId] ?? "Player",
                placement: podResult.placement,
                totalPoints: podResult.totalPoints,
                isSelf: podResult.playerId == playerId
            )
        }

        let earnedAchievements = result.achievementIds.compactMap { achievementNames[$0] }
        let summary = PlayerRoundSummary(
            id: result.id,
            tournamentId: result.tournamentId,
            tournamentName: tournamentName,
            week: result.week,
            round: result.round,
            placement: result.placement,
            totalPoints: result.totalPoints,
            achievementCount: result.achievementIds.count,
            timestamp: result.timestamp,
            isWin: result.isWin,
            podId: result.podId
        )

        return PlayerRoundDetail(
            summary: summary,
            placementPoints: result.placementPoints,
            achievementPoints: result.achievementPoints,
            achievements: earnedAchievements,
            podmates: podmates
        )
    }

    /// Round detail with resolved tournament name.
    static func roundDetail(
        resultId: String,
        playerId: String,
        results: [GameResult],
        players: [Player],
        achievements: [Achievement],
        tournaments: [Tournament]
    ) -> PlayerRoundDetail? {
        guard var detail = roundDetail(
            resultId: resultId,
            playerId: playerId,
            results: results,
            players: players,
            achievements: achievements
        ) else { return nil }

        let tournamentNames = Dictionary(uniqueKeysWithValues: tournaments.map { ($0.id, $0.name) })
        let name = tournamentNames[detail.summary.tournamentId] ?? detail.summary.tournamentName
        detail.summary = PlayerRoundSummary(
            id: detail.summary.id,
            tournamentId: detail.summary.tournamentId,
            tournamentName: name,
            week: detail.summary.week,
            round: detail.summary.round,
            placement: detail.summary.placement,
            totalPoints: detail.summary.totalPoints,
            achievementCount: detail.summary.achievementCount,
            timestamp: detail.summary.timestamp,
            isWin: detail.summary.isWin,
            podId: detail.summary.podId
        )
        return detail
    }

    /// Win streak and placement highlights for the hero card.
    static func playerFormHighlights(playerId: String, results: [GameResult]) -> PlayerFormHighlights {
        let placements = results
            .filter { $0.playerId == playerId }
            .sorted {
                if $0.week != $1.week { return $0.week < $1.week }
                if $0.round != $1.round { return $0.round < $1.round }
                return $0.timestamp < $1.timestamp
            }
            .map(\.placement)

        var currentWinStreak = 0
        for placement in placements.reversed() {
            guard placement == 1 else { break }
            currentWinStreak += 1
        }

        let firstPlaceCount = placements.filter { $0 == 1 }.count
        var bestWinStreak = 0
        var running = 0
        for placement in placements {
            if placement == 1 {
                running += 1
                bestWinStreak = max(bestWinStreak, running)
            } else {
                running = 0
            }
        }

        return PlayerFormHighlights(
            currentWinStreak: currentWinStreak,
            bestWinStreak: bestWinStreak,
            firstPlaceCount: firstPlaceCount
        )
    }
}

// MARK: - Supporting Types

/// Stats for a player within a specific tournament.
struct TournamentPlayerStats {
    let gamesPlayed: Int
    let wins: Int
    let totalPoints: Int
    let placementPoints: Int
    let achievementPoints: Int
    let placementDistribution: [Int: Int]
    let averagePlacement: Double
    let winRate: Double
}

/// Head-to-head record between two players.
struct HeadToHeadRecord {
    let player1Wins: Int
    let player2Wins: Int
    let ties: Int
    
    var totalGames: Int {
        player1Wins + player2Wins + ties
    }
}

/// Summary of a tournament.
struct TournamentSummary {
    let participantCount: Int
    let totalGames: Int
    let winnerName: String?
    let winnerPoints: Int
    let standings: [(player: Player, points: Int)]
}

/// A single scored round for player history lists.
struct PlayerRoundSummary: Identifiable {
    let id: String
    let tournamentId: String
    var tournamentName: String
    let week: Int
    let round: Int
    let placement: Int
    let totalPoints: Int
    let achievementCount: Int
    let timestamp: Date
    let isWin: Bool
    let podId: String

    var weekRoundLabel: String {
        "Week \(week) · Round \(round)"
    }

    var placementLabel: String {
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(placement)"
        }
    }
}

/// Podmate row for round detail.
struct PodmateResult: Identifiable {
    var id: String { "\(playerName)-\(placement)" }
    let playerName: String
    let placement: Int
    let totalPoints: Int
    let isSelf: Bool

    var placementLabel: String {
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(placement)"
        }
    }
}

/// Full detail for a player round sheet.
struct PlayerRoundDetail {
    var summary: PlayerRoundSummary
    let placementPoints: Int
    let achievementPoints: Int
    let achievements: [String]
    let podmates: [PodmateResult]
}

/// Scope for filtering player detail stats.
enum PlayerDetailScope: Hashable, Identifiable {
    case allTime
    case tournament(id: String, name: String)

    var id: String {
        switch self {
        case .allTime: return "all-time"
        case .tournament(let id, _): return id
        }
    }

    var title: String {
        switch self {
        case .allTime: return "All-Time"
        case .tournament(_, let name): return name
        }
    }
}

/// Attendance rollup for one tournament.
struct PlayerAttendanceSummary: Identifiable {
    var id: String { tournamentId }
    let tournamentId: String
    let tournamentName: String
    let weeksPresent: Int
    let weeksTotal: Int

    var percentage: Int {
        guard weeksTotal > 0 else { return 0 }
        return Int((Double(weeksPresent) / Double(weeksTotal) * 100).rounded())
    }

    var summaryLabel: String {
        "\(weeksPresent) of \(weeksTotal) weeks (\(percentage)%)"
    }
}

/// Placement streak highlights for player detail hero.
struct PlayerFormHighlights {
    let currentWinStreak: Int
    let bestWinStreak: Int
    let firstPlaceCount: Int

    var displayText: String? {
        if currentWinStreak >= 2 {
            return "\(currentWinStreak) wins in a row"
        }
        if bestWinStreak >= 3 {
            return "Best streak: \(bestWinStreak) wins"
        }
        if firstPlaceCount >= 2 {
            return "1st place ×\(firstPlaceCount)"
        }
        return nil
    }
}
