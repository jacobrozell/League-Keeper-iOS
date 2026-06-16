import Foundation
import SwiftData

/// ViewModel for the Attendance view.
/// Manages player attendance and weekly settings.
@Observable
final class AttendanceViewModel {
    private let context: ModelContext
    
    // MARK: - Published State
    
    var players: [Player] = []
    var currentWeek: Int = 1
    var achievementsOnThisWeek: Bool = true
    var presentStatus: [String: Bool] = [:] // playerId -> isPresent
    var newPlayerName: String = ""
    
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

    var podLayoutHint: String? {
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
        
        // No tournament or no saved attendance: default all to present where not yet set
        for player in players where presentStatus[player.id] == nil {
            presentStatus[player.id] = true
        }
    }
    
    /// Toggles a player's presence.
    func togglePresence(for playerId: String) {
        presentStatus[playerId] = !(presentStatus[playerId] ?? false)
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
        if let player = LeagueEngine.addWeeklyPlayer(context: context, name: newPlayerName) {
            presentStatus[player.id] = true
        }
        newPlayerName = ""
        refresh()
    }
    
    /// Confirms attendance and proceeds to pods.
    func confirmAttendance() {
        guard canConfirmAttendance else { return }
        LeagueEngine.confirmAttendance(
            context: context,
            presentIds: presentPlayerIds,
            achievementsOnThisWeek: achievementsOnThisWeek
        )
    }
}
