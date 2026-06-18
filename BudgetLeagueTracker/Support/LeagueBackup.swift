import Foundation
import SwiftData

// MARK: - Backup file format

/// Portable JSON backup of all league data on device.
struct LeagueBackupFile: Codable, Equatable {
    let formatVersion: Int
    let exportedAt: Date
    let appDisplayName: String
    /// Optional instructions included in downloadable import templates only.
    let readme: String?
    let players: [PlayerBackup]
    let achievements: [AchievementBackup]
    let tournaments: [TournamentBackup]
    let gameResults: [GameResultBackup]
    let leagueState: LeagueStateBackup?

    static let currentFormatVersion = 1

    init(
        formatVersion: Int,
        exportedAt: Date,
        appDisplayName: String,
        readme: String? = nil,
        players: [PlayerBackup],
        achievements: [AchievementBackup],
        tournaments: [TournamentBackup],
        gameResults: [GameResultBackup],
        leagueState: LeagueStateBackup?
    ) {
        self.formatVersion = formatVersion
        self.exportedAt = exportedAt
        self.appDisplayName = appDisplayName
        self.readme = readme
        self.players = players
        self.achievements = achievements
        self.tournaments = tournaments
        self.gameResults = gameResults
        self.leagueState = leagueState
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        formatVersion = try container.decode(Int.self, forKey: .formatVersion)
        exportedAt = try container.decode(Date.self, forKey: .exportedAt)
        appDisplayName = try container.decode(String.self, forKey: .appDisplayName)
        readme = try container.decodeIfPresent(String.self, forKey: .readme)
        players = try container.decode([PlayerBackup].self, forKey: .players)
        achievements = try container.decode([AchievementBackup].self, forKey: .achievements)
        tournaments = try container.decode([TournamentBackup].self, forKey: .tournaments)
        gameResults = try container.decode([GameResultBackup].self, forKey: .gameResults)
        leagueState = try container.decodeIfPresent(LeagueStateBackup.self, forKey: .leagueState)
    }
}

struct PlayerBackup: Codable, Equatable {
    let id: String
    let name: String
    let nameNote: String?
    let placementPoints: Int
    let achievementPoints: Int
    let wins: Int
    let gamesPlayed: Int
    let tournamentsPlayed: Int
}

struct AchievementBackup: Codable, Equatable {
    let id: String
    let name: String
    let points: Int
    let alwaysOn: Bool
    let achievementDescription: String?
    let categoryRaw: String
    let iconName: String
    let exclusivityRaw: String
}

struct TournamentBackup: Codable, Equatable {
    let id: String
    let name: String
    let totalWeeks: Int
    let randomAchievementsPerWeek: Int
    let startDate: Date
    let endDate: Date?
    let statusRaw: String
    let currentWeek: Int
    let currentRound: Int
    let achievementsOnThisWeek: Bool
    let presentPlayerIds: [String]
    let weeklyPointsByPlayer: [String: WeeklyPlayerPoints]
    let activeAchievementIds: [String]
    let attendanceHistory: [WeekAttendanceSnapshot]
    let podHistorySnapshots: [PodSnapshot]
    let roundPlacements: [String: Int]
    let currentRoundPodsPlayerIds: [[String]]
    let roundAchievementChecks: [String]
    let confirmedTableIndices: [Int]
    let tableScoringOrders: [[String]]
    let roundScoringStarted: Bool
    let standingsBasedSeating: Bool
    let rules: TournamentRules
}

struct GameResultBackup: Codable, Equatable {
    let id: String
    let tournamentId: String
    let week: Int
    let round: Int
    let playerId: String
    let placement: Int
    let placementPoints: Int
    let achievementPoints: Int
    let achievementIds: [String]
    let timestamp: Date
    let podId: String
}

struct LeagueStateBackup: Codable, Equatable {
    let activeTournamentId: String?
    let currentScreen: String
}

// MARK: - Service

/// Human-readable summary shown before confirming import.
struct LeagueBackupImportPreview: Equatable {
    let playerCount: Int
    let achievementCount: Int
    let tournamentCount: Int
    let activeTournamentName: String?
    let isTemplate: Bool

    var confirmationMessage: String {
        var lines: [String] = []
        if isTemplate {
            lines.append("This looks like a starter template.")
        }
        lines.append("\(playerCount) players · \(achievementCount) achievements · \(tournamentCount) tournaments")
        if let activeTournamentName {
            lines.append("Active league: \(activeTournamentName)")
        }
        lines.append("Import replaces everything currently on this device.")
        return lines.joined(separator: "\n")
    }

    var successMessage: String {
        if isTemplate {
            return "League imported. Open Tournaments to mark attendance and start Week 1."
        }
        return "League data restored from backup."
    }
}

enum LeagueBackupError: LocalizedError {
    case exportFailed
    case invalidFormat
    case unsupportedVersion(Int)
    case importFailed(String)

    var errorDescription: String? {
        switch self {
        case .exportFailed:
            return "Could not export league data."
        case .invalidFormat:
            return "The selected file is not a valid League Keeper backup."
        case .unsupportedVersion(let version):
            return "Backup format version \(version) is not supported."
        case .importFailed(let detail):
            return "Import failed: \(detail)"
        }
    }
}

enum LeagueBackupService {
  /// Encodes all persisted league data as JSON.
  static func makeBackupFile(context: ModelContext) throws -> LeagueBackupFile {
    let players = (try? context.fetch(FetchDescriptor<Player>())) ?? []
    let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
    let tournaments = (try? context.fetch(FetchDescriptor<Tournament>())) ?? []
    let gameResults = (try? context.fetch(FetchDescriptor<GameResult>())) ?? []
    let leagueStates = (try? context.fetch(FetchDescriptor<LeagueState>())) ?? []

    return LeagueBackupFile(
      formatVersion: LeagueBackupFile.currentFormatVersion,
      exportedAt: Date(),
      appDisplayName: AppInfo.displayName,
      readme: nil,
      players: players.map(PlayerBackup.init),
      achievements: achievements.map(AchievementBackup.init),
      tournaments: tournaments.map(TournamentBackup.init),
      gameResults: gameResults.map(GameResultBackup.init),
      leagueState: leagueStates.first.map(LeagueStateBackup.init)
    )
  }

  /// Starter JSON for hosts who want to edit names and settings on a computer, then import.
  static func makeImportTemplate() -> LeagueBackupFile {
    LeagueImportTemplate.make()
  }

  static func templateData() throws -> Data {
    let backup = makeImportTemplate()
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(backup) else {
      throw LeagueBackupError.exportFailed
    }
    return data
  }

  static func templateURL() throws -> URL {
    let data = try templateData()
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("League-Keeper-import-template.json")
    try data.write(to: url, options: .atomic)
    return url
  }

  static func exportData(context: ModelContext) throws -> Data {
    let backup = try makeBackupFile(context: context)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    guard let data = try? encoder.encode(backup) else {
      throw LeagueBackupError.exportFailed
    }
    return data
  }

  static func exportURL(context: ModelContext) throws -> URL {
    let data = try exportData(context: context)
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let filename = "League-Keeper-backup-\(formatter.string(from: Date())).json"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    try data.write(to: url, options: .atomic)
    return url
  }

  /// Parses a backup file for the import confirmation sheet (does not mutate data).
  static func previewImport(_ data: Data) -> LeagueBackupImportPreview? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    guard let backup = try? decoder.decode(LeagueBackupFile.self, from: data) else { return nil }
    guard backup.formatVersion <= LeagueBackupFile.currentFormatVersion else { return nil }

    let activeName = backup.leagueState?.activeTournamentId.flatMap { activeId in
      backup.tournaments.first(where: { $0.id == activeId })?.name
    }

    return LeagueBackupImportPreview(
      playerCount: backup.players.count,
      achievementCount: backup.achievements.count,
      tournamentCount: backup.tournaments.count,
      activeTournamentName: activeName,
      isTemplate: backup.readme != nil
    )
  }

  /// Replaces all league data with the contents of a backup file.
  static func importBackup(_ data: Data, context: ModelContext) throws {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    guard let backup = try? decoder.decode(LeagueBackupFile.self, from: data) else {
      throw LeagueBackupError.invalidFormat
    }
    guard backup.formatVersion <= LeagueBackupFile.currentFormatVersion else {
      throw LeagueBackupError.unsupportedVersion(backup.formatVersion)
    }

    try deleteAll(context: context)
    try insertAll(backup: backup, context: context)
    try context.save()
    LeagueEngine.validateAndSanitizeState(context: context)
  }

  private static func deleteAll(context: ModelContext) throws {
    for result in (try? context.fetch(FetchDescriptor<GameResult>())) ?? [] {
      context.delete(result)
    }
    for tournament in (try? context.fetch(FetchDescriptor<Tournament>())) ?? [] {
      context.delete(tournament)
    }
    for player in (try? context.fetch(FetchDescriptor<Player>())) ?? [] {
      context.delete(player)
    }
    for achievement in (try? context.fetch(FetchDescriptor<Achievement>())) ?? [] {
      context.delete(achievement)
    }
    for state in (try? context.fetch(FetchDescriptor<LeagueState>())) ?? [] {
      context.delete(state)
    }
  }

  private static func insertAll(backup: LeagueBackupFile, context: ModelContext) throws {
    if let stateBackup = backup.leagueState {
      context.insert(stateBackup.makeModel())
    } else {
      context.insert(LeagueState())
    }

    for achievementBackup in backup.achievements {
      context.insert(achievementBackup.makeModel())
    }
    for playerBackup in backup.players {
      context.insert(playerBackup.makeModel())
    }
    for tournamentBackup in backup.tournaments {
      context.insert(tournamentBackup.makeModel())
    }
    for resultBackup in backup.gameResults {
      context.insert(resultBackup.makeModel())
    }

    if backup.achievements.isEmpty {
      let defaultAchievement = Achievement(
        name: AppConstants.DefaultAchievement.name,
        points: AppConstants.DefaultAchievement.points,
        alwaysOn: AppConstants.DefaultAchievement.alwaysOn,
        achievementDescription: AppConstants.DefaultAchievement.achievementDescription,
        category: AppConstants.DefaultAchievement.category,
        iconName: AppConstants.DefaultAchievement.iconName,
        exclusivity: AppConstants.DefaultAchievement.exclusivity
      )
      context.insert(defaultAchievement)
    }
  }
}

// MARK: - Import template

/// Stable IDs and sample content for the downloadable import template.
private enum LeagueImportTemplate {
  static let tournamentId = "template-tournament-1"

  static let playerIDs = (1...8).map { "template-player-\($0)" }

  static let achievementIDs = [
    "template-ach-first-blood",
    "template-ach-combat-master",
    "template-ach-five-color",
  ]

  static func make() -> LeagueBackupFile {
    let players = playerIDs.enumerated().map { index, id in
      PlayerBackup(
        id: id,
        name: "Player \(index + 1)",
        nameNote: nil,
        placementPoints: 0,
        achievementPoints: 0,
        wins: 0,
        gamesPlayed: 0,
        tournamentsPlayed: 1
      )
    }

    let achievements = [
      AchievementBackup(
        id: achievementIDs[0],
        name: AppConstants.DefaultAchievement.name,
        points: AppConstants.DefaultAchievement.points,
        alwaysOn: false,
        achievementDescription: AppConstants.DefaultAchievement.achievementDescription,
        categoryRaw: AppConstants.DefaultAchievement.category.rawValue,
        iconName: AppConstants.DefaultAchievement.iconName,
        exclusivityRaw: AppConstants.DefaultAchievement.exclusivity.rawValue
      ),
      AchievementBackup(
        id: achievementIDs[1],
        name: "Combat Damage Master",
        points: 2,
        alwaysOn: false,
        achievementDescription: "Deal 10 or more combat damage to a single player in one turn",
        categoryRaw: AchievementCategory.combat.rawValue,
        iconName: "bolt.fill",
        exclusivityRaw: AchievementExclusivity.unlimited.rawValue
      ),
      AchievementBackup(
        id: achievementIDs[2],
        name: "Five-Color Flavor",
        points: 1,
        alwaysOn: false,
        achievementDescription: "Cast a spell of each color in one game",
        categoryRaw: AchievementCategory.deckbuilding.rawValue,
        iconName: "paintpalette.fill",
        exclusivityRaw: AchievementExclusivity.onePerPod.rawValue
      ),
    ]

    let tournament = TournamentBackup(
      id: tournamentId,
      name: "My League (rename me)",
      totalWeeks: AppConstants.League.defaultTotalWeeks,
      randomAchievementsPerWeek: AppConstants.League.defaultRandomAchievementsPerWeek,
      startDate: Date(),
      endDate: nil,
      statusRaw: TournamentStatus.ongoing.rawValue,
      currentWeek: 1,
      currentRound: 1,
      achievementsOnThisWeek: true,
      presentPlayerIds: [],
      weeklyPointsByPlayer: [:],
      activeAchievementIds: [],
      attendanceHistory: [],
      podHistorySnapshots: [],
      roundPlacements: [:],
      currentRoundPodsPlayerIds: [],
      roundAchievementChecks: [],
      confirmedTableIndices: [],
      tableScoringOrders: [],
      roundScoringStarted: false,
      standingsBasedSeating: AppConstants.League.defaultStandingsBasedSeating,
      rules: AppConstants.TournamentRulesDefaults.defaultRules
    )

    return LeagueBackupFile(
      formatVersion: LeagueBackupFile.currentFormatVersion,
      exportedAt: Date(),
      appDisplayName: AppInfo.displayName,
      readme: readmeText,
      players: players,
      achievements: achievements,
      tournaments: [tournament],
      gameResults: [],
      leagueState: LeagueStateBackup(
        activeTournamentId: tournamentId,
        currentScreen: Screen.tournaments.rawValue
      )
    )
  }

  private static let readmeText = """
  League Keeper import template

  HOW TO USE
  1. Edit this file in any text editor (or Numbers/Excel after converting).
  2. Change player names under "players" — keep each "id" the same.
  3. Rename the tournament under "tournaments" → "name".
  4. Adjust "totalWeeks" and "randomAchievementsPerWeek" if needed.
  5. Edit achievement names, points, and descriptions under "achievements".
  6. Save as JSON, then in League Keeper: Settings → Import league data.

  TIPS
  • To add players: duplicate a player object with a new unique "id", then add that id to your roster in the app after import.
  • To remove players: delete their object from "players" (scores are empty in this template).
  • For mid-season restores, export from the app instead of using this template.
  • Do not change "formatVersion".
  """
}

// MARK: - Model mapping

private extension PlayerBackup {
  init(_ player: Player) {
    id = player.id
    name = player.name
    nameNote = player.nameNote
    placementPoints = player.placementPoints
    achievementPoints = player.achievementPoints
    wins = player.wins
    gamesPlayed = player.gamesPlayed
    tournamentsPlayed = player.tournamentsPlayed
  }

  func makeModel() -> Player {
    Player(
      id: id,
      name: name,
      nameNote: nameNote,
      placementPoints: placementPoints,
      achievementPoints: achievementPoints,
      wins: wins,
      gamesPlayed: gamesPlayed,
      tournamentsPlayed: tournamentsPlayed
    )
  }
}

private extension AchievementBackup {
  init(_ achievement: Achievement) {
    id = achievement.id
    name = achievement.name
    points = achievement.points
    alwaysOn = achievement.alwaysOn
    achievementDescription = achievement.achievementDescription
    categoryRaw = achievement.categoryRaw
    iconName = achievement.iconName
    exclusivityRaw = achievement.exclusivityRaw
  }

  func makeModel() -> Achievement {
    let model = Achievement(
      id: id,
      name: name,
      points: points,
      alwaysOn: alwaysOn,
      achievementDescription: achievementDescription,
      category: AchievementCategory(rawValue: categoryRaw) ?? .custom,
      iconName: iconName,
      exclusivity: AchievementExclusivity(rawValue: exclusivityRaw) ?? .unlimited
    )
    return model
  }
}

private extension TournamentBackup {
  init(_ tournament: Tournament) {
    id = tournament.id
    name = tournament.name
    totalWeeks = tournament.totalWeeks
    randomAchievementsPerWeek = tournament.randomAchievementsPerWeek
    startDate = tournament.startDate
    endDate = tournament.endDate
    statusRaw = tournament.statusRaw
    currentWeek = tournament.currentWeek
    currentRound = tournament.currentRound
    achievementsOnThisWeek = tournament.achievementsOnThisWeek
    presentPlayerIds = tournament.presentPlayerIds
    weeklyPointsByPlayer = tournament.weeklyPointsByPlayer
    activeAchievementIds = tournament.activeAchievementIds
    attendanceHistory = tournament.attendanceHistory
    podHistorySnapshots = tournament.podHistorySnapshots
    roundPlacements = tournament.roundPlacements
    currentRoundPodsPlayerIds = tournament.currentRoundPodsPlayerIds
    roundAchievementChecks = Array(tournament.roundAchievementChecks)
    confirmedTableIndices = Array(tournament.confirmedTableIndices).sorted()
    tableScoringOrders = tournament.tableScoringOrders
    roundScoringStarted = tournament.roundScoringStarted
    standingsBasedSeating = tournament.standingsBasedSeating
    rules = tournament.rules
  }

  func makeModel() -> Tournament {
    let tournament = Tournament(
      id: id,
      name: name,
      totalWeeks: totalWeeks,
      randomAchievementsPerWeek: randomAchievementsPerWeek,
      startDate: startDate,
      endDate: endDate,
      status: TournamentStatus(rawValue: statusRaw) ?? .ongoing,
      currentWeek: currentWeek,
      currentRound: currentRound,
      achievementsOnThisWeek: achievementsOnThisWeek,
      rules: rules
    )
    tournament.presentPlayerIds = presentPlayerIds
    tournament.weeklyPointsByPlayer = weeklyPointsByPlayer
    tournament.activeAchievementIds = activeAchievementIds
    tournament.attendanceHistory = attendanceHistory
    tournament.podHistorySnapshots = podHistorySnapshots
    tournament.roundPlacements = roundPlacements
    tournament.currentRoundPodsPlayerIds = currentRoundPodsPlayerIds
    tournament.roundAchievementChecks = Set(roundAchievementChecks)
    tournament.confirmedTableIndices = Set(confirmedTableIndices)
    tournament.tableScoringOrders = tableScoringOrders
    tournament.roundScoringStarted = roundScoringStarted
    tournament.standingsBasedSeating = standingsBasedSeating
    return tournament
  }
}

private extension GameResultBackup {
  init(_ result: GameResult) {
    id = result.id
    tournamentId = result.tournamentId
    week = result.week
    round = result.round
    playerId = result.playerId
    placement = result.placement
    placementPoints = result.placementPoints
    achievementPoints = result.achievementPoints
    achievementIds = result.achievementIds
    timestamp = result.timestamp
    podId = result.podId
  }

  func makeModel() -> GameResult {
    GameResult(
      id: id,
      tournamentId: tournamentId,
      week: week,
      round: round,
      playerId: playerId,
      placement: placement,
      placementPoints: placementPoints,
      achievementPoints: achievementPoints,
      achievementIds: achievementIds,
      timestamp: timestamp,
      podId: podId
    )
  }
}

private extension LeagueStateBackup {
  init(_ state: LeagueState) {
    activeTournamentId = state.activeTournamentId
    currentScreen = state.currentScreen
  }

  func makeModel() -> LeagueState {
    LeagueState(activeTournamentId: activeTournamentId, currentScreen: currentScreen)
  }
}
