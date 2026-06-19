import Foundation
import SwiftData

/// Scans persisted models for JSON decode failures.
enum DataHealthChecker {
    struct Issue: Equatable, Identifiable {
        let id: String
        let message: String
        let repairHint: String
    }

    static func scan(context: ModelContext) -> [Issue] {
        let tournaments = (try? context.fetch(FetchDescriptor<Tournament>())) ?? []
        return tournaments.flatMap { issues(for: $0) }
    }

    private static func issues(for tournament: Tournament) -> [Issue] {
        var found: [Issue] = []

        check(tournament.presentPlayerIdsData, as: [String].self, field: "present players", hint: "Confirm attendance again for the current week.", tournament: tournament, into: &found)
        check(tournament.weeklyPointsJSON, as: [String: WeeklyPlayerPoints].self, field: "weekly points", hint: "Export a backup, then contact support if standings look wrong.", tournament: tournament, into: &found)
        check(tournament.activeAchievementIdsData, as: [String].self, field: "active achievements", hint: "Start a new week or re-open attendance to roll achievements again.", tournament: tournament, into: &found)
        check(tournament.attendanceHistoryData, as: [WeekAttendanceSnapshot].self, field: "attendance history", hint: "Export a backup before editing attendance records.", tournament: tournament, into: &found)
        check(tournament.podHistoryData, as: [PodSnapshot].self, field: "round history", hint: "Export a backup before editing past rounds.", tournament: tournament, into: &found)
        check(tournament.roundPlacementsData, as: [String: Int].self, field: "current round scores", hint: "Re-score the current round or clear table seatings and start over.", tournament: tournament, into: &found)
        check(tournament.currentRoundPodsPlayerIdsData, as: [[String]].self, field: "table seatings", hint: "Seat players again for the current round.", tournament: tournament, into: &found)
        check(tournament.roundAchievementChecksData, as: Set<String>.self, field: "achievement checks", hint: "Re-score achievements for the current round.", tournament: tournament, into: &found)
        check(tournament.confirmedTableIndicesData, as: Set<Int>.self, field: "confirmed tables", hint: "Re-score tables for the current round.", tournament: tournament, into: &found)
        check(tournament.tableScoringOrdersData, as: [[String]].self, field: "table finish order", hint: "Re-score the current round to restore finish order.", tournament: tournament, into: &found)
        check(tournament.rulesData, as: TournamentRules.self, field: "house rules", hint: "Re-open house rules and save them again.", tournament: tournament, into: &found)

        return found
    }

    private static func check<T: Decodable>(
        _ data: Data?,
        as type: T.Type,
        field: String,
        hint: String,
        tournament: Tournament,
        into found: inout [Issue]
    ) {
        if failsDecode(data, as: type, field: field, tournament: tournament) {
            found.append(issue(tournament, field: field, hint: hint))
        }
    }

    private static func failsDecode<T: Decodable>(_ data: Data?, as type: T.Type, field: String, tournament: Tournament) -> Bool {
        guard let data, !data.isEmpty else { return false }
        if (try? JSONDecoder().decode(type, from: data)) != nil {
            return false
        }
        AppLog.shared.error(
            .persistence,
            eventName: "tournament_json_decode_failed",
            message: "Corrupt tournament JSON field",
            metadata: ["field": field, "tournamentId": tournament.id]
        )
        return true
    }

    private static func issue(_ tournament: Tournament, field: String, hint: String) -> Issue {
        Issue(
            id: "\(tournament.id)-\(field)",
            message: "\(tournament.name): could not read \(field).",
            repairHint: hint
        )
    }
}
