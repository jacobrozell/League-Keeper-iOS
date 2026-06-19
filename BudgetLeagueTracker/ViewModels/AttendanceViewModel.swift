import Foundation
import SwiftData

/// ViewModel for the Attendance view.
/// Manages player attendance and weekly settings.
@MainActor
@Observable
final class AttendanceViewModel {
    private let context: ModelContext
    
    // MARK: - Published State
    
    var players: [Player] = []
    var currentWeek: Int = 1
    var achievementsOnThisWeek: Bool = true
    var presentStatus: [String: Bool] = [:] // playerId -> isPresent
    var newPlayerName: String = ""
    /// Whether the last confirm cleared table seatings (host should reseat).
    private(set) var lastConfirmClearedTables = false
    /// Set when a save fails during confirm/update.
    private(set) var lastSaveFailed = false
    
    var presentPlayerIds: [String] {
        presentStatus.filter { $0.value }.map { $0.key }
    }
    
    var canConfirmAttendance: Bool {
        !presentPlayerIds.isEmpty
    }

    var presentCountLabel: String {
        let present = presentPlayerIds.count
        let total = players.count
        guard total > 0 else { return "0 present" }
        return "\(present) of \(total) present"
    }

    var tableLayoutHint: String? {
        PodLayoutHint.message(presentCount: presentPlayerIds.count)
    }

    /// True when attendance has already been saved for the active tournament week.
    var isAttendanceConfirmed: Bool {
        guard let tournament = LeagueEngine.fetchActiveTournament(context: context) else { return false }
        return !tournament.presentPlayerIds.isEmpty
    }
    
    // MARK: - Initialization
    
    init(context: ModelContext) {
        self.context = context
        refresh()
    }
    
    // MARK: - Actions
    
    /// Refreshes state from SwiftData.
    func refresh() {
        let descriptor = FetchDescriptor<Player>(sortBy: [SortDescriptor(\.name)])
        players = (try? context.fetch(descriptor)) ?? []
        
        if let tournament = LeagueEngine.fetchActiveTournament(context: context) {
            currentWeek = tournament.currentWeek
            achievementsOnThisWeek = tournament.achievementsOnThisWeek
            let savedPresentIds = tournament.presentPlayerIds
            if !savedPresentIds.isEmpty {
                for player in players {
                    presentStatus[player.id] = savedPresentIds.contains(player.id)
                }
                return
            }
        }
        
        // No saved attendance: default absent so hosts consciously mark who's here
        for player in players where presentStatus[player.id] == nil {
            presentStatus[player.id] = false
        }
    }
    
    /// Toggles a player's presence.
    func togglePresence(for playerId: String) {
        presentStatus[playerId] = !(presentStatus[playerId] ?? false)
    }

    func displayName(for player: Player) -> String {
        PlayerDisambiguation.displayName(for: player, among: players)
    }

    /// Marks every league player as present for this week.
    func markAllPresent() {
        for player in players {
            presentStatus[player.id] = true
        }
    }

    /// Clears presence for every league player.
    func markAllAbsent() {
        for player in players {
            presentStatus[player.id] = false
        }
    }
    
    /// Returns whether a player is present.
    func isPresent(_ playerId: String) -> Bool {
        presentStatus[playerId] ?? false
    }
    
    /// Adds a new player during attendance (joins league and is marked present).
    func addWeeklyPlayer() {
        guard !newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        lastSaveFailed = false
        if let player = LeagueEngine.addWeeklyPlayer(context: context, name: newPlayerName) {
            presentStatus[player.id] = true
            newPlayerName = ""
            refresh()
        } else {
            lastSaveFailed = true
        }
    }
    
    /// Confirms or updates attendance for the current week.
    /// Sets `lastConfirmClearedTables` when a mid-week roster change cleared table seatings.
    /// Returns `false` when persistence failed.
    @discardableResult
    func confirmAttendance() -> Bool {
        guard canConfirmAttendance else { return false }
        lastConfirmClearedTables = false
        lastSaveFailed = false
        if isAttendanceConfirmed {
            let result = LeagueEngine.updateAttendance(
                context: context,
                presentIds: presentPlayerIds,
                achievementsOnThisWeek: achievementsOnThisWeek
            )
            lastConfirmClearedTables = result.clearedTables
            lastSaveFailed = !result.saved
            return result.saved
        }
        let saved = LeagueEngine.confirmAttendance(
            context: context,
            presentIds: presentPlayerIds,
            achievementsOnThisWeek: achievementsOnThisWeek
        )
        lastSaveFailed = !saved
        return saved
    }
}
