import Foundation
import SwiftData

/// Launch-argument routing for marketing and evidence screenshots.
@MainActor
enum UITestSnapshot {
    static let marketingSeed = "UI-Testing-Marketing-Seed"
    private static let snapshotPrefix = "UI-Testing-Snapshot-"

    enum MainTab: String {
        case stats = "TabStats"
        case achievements = "TabAchievements"
        case settings = "TabSettings"
    }

    enum DetailTab: String {
        case attendance = "DetailAttendance"
        case round = "DetailRound"
        case standings = "DetailStandings"
    }

    enum Target: Equatable {
        case tournamentsList
        case detail(DetailTab)
        case mainTab(MainTab)
    }

    private(set) static var pendingTarget: Target?
    private(set) static var pendingDetailTab: TournamentDetailTab?
    private(set) static var pendingMainTab: ContentViewSnapshotTab?

    /// Parses `UI-Testing-Snapshot-*` from launch arguments.
    static func parseTarget(from arguments: [String]) -> Target? {
        guard let raw = arguments.first(where: { $0.hasPrefix(snapshotPrefix) }) else { return nil }
        let name = String(raw.dropFirst(snapshotPrefix.count))
        switch name {
        case "TournamentsList":
            return .tournamentsList
        case DetailTab.attendance.rawValue:
            return .detail(.attendance)
        case DetailTab.round.rawValue:
            return .detail(.round)
        case DetailTab.standings.rawValue:
            return .detail(.standings)
        case MainTab.stats.rawValue:
            return .mainTab(.stats)
        case MainTab.achievements.rawValue:
            return .mainTab(.achievements)
        case MainTab.settings.rawValue:
            return .mainTab(.settings)
        default:
            return nil
        }
    }

    static func configure(from arguments: [String]) {
        pendingTarget = parseTarget(from: arguments)
        pendingDetailTab = nil
        pendingMainTab = nil

        guard let pendingTarget else { return }

        switch pendingTarget {
        case .tournamentsList:
            break
        case .detail(let tab):
            pendingDetailTab = tournamentDetailTab(for: tab)
        case .mainTab(let tab):
            pendingMainTab = contentTab(for: tab)
        }
    }

    static func consumePendingDetailTab() -> TournamentDetailTab? {
        defer { pendingDetailTab = nil }
        return pendingDetailTab
    }

    static func consumePendingMainTab() -> ContentViewSnapshotTab? {
        defer { pendingMainTab = nil }
        return pendingMainTab
    }

    /// Seeds demo league data appropriate for the snapshot target.
    static func seedMarketingIfNeeded(context: ModelContext, arguments: [String]) {
        guard arguments.contains(marketingSeed), let target = parseTarget(from: arguments) else { return }

        pendingTarget = target
        configure(from: arguments)

        UITestBootstrap.resetAllData(in: context)

        do {
            try DemoLeagueLoader.load(into: context)
        } catch {
            return
        }

        let playerIds = fetchDemoPlayerIds(in: context)
        guard !playerIds.isEmpty else { return }

        switch target {
        case .tournamentsList, .mainTab(.achievements), .mainTab(.settings):
            LeagueEngine.setScreen(context: context, screen: .tournaments)
        case .detail(.attendance):
            LeagueEngine.setScreen(context: context, screen: .tournaments)
            UITestBootstrap.queueTournamentNavigation(name: DemoLeagueLoader.tournamentName)
        case .detail(.round):
            LeagueEngine.confirmAttendance(
                context: context,
                presentIds: playerIds,
                achievementsOnThisWeek: true
            )
            LeagueEngine.setScreen(context: context, screen: .tournaments)
            UITestBootstrap.queueTournamentNavigation(name: DemoLeagueLoader.tournamentName)
        case .detail(.standings):
            UITestBootstrap.seedScoredRound(in: context)
            LeagueEngine.setScreen(context: context, screen: .tournaments)
            UITestBootstrap.queueTournamentNavigation(name: DemoLeagueLoader.tournamentName)
        case .mainTab(.stats):
            UITestBootstrap.seedScoredRound(in: context)
            LeagueEngine.setScreen(context: context, screen: .tournaments)
        }

        try? context.save()
    }

    private static func tournamentDetailTab(for tab: DetailTab) -> TournamentDetailTab {
        switch tab {
        case .attendance: return .attendance
        case .round: return .round
        case .standings: return .standings
        }
    }

    private static func contentTab(for tab: MainTab) -> ContentViewSnapshotTab {
        switch tab {
        case .stats: return .stats
        case .achievements: return .achievements
        case .settings: return .settings
        }
    }

    private static func fetchDemoPlayerIds(in context: ModelContext) -> [String] {
        let descriptor = FetchDescriptor<Player>()
        let players = (try? context.fetch(descriptor)) ?? []
        return players.map(\.id)
    }
}

/// Tab selection applied from snapshot launch args (`ContentView`).
enum ContentViewSnapshotTab {
    case stats
    case achievements
    case settings
}
