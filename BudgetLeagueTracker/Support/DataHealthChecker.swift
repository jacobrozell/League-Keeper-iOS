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

        if failsDecode(tournament.presentPlayerIdsData, as: [String].self, field: "present players", tournament: tournament) {
            found.append(issue(tournament, field: "present players", hint: "Confirm attendance again for the current week."))
        }
        if failsDecode(tournament.weeklyPointsJSON, as: [String: WeeklyPlayerPoints].self, field: "weekly points", tournament: tournament) {
            found.append(issue(tournament, field: "weekly points", hint: "Export a backup, then contact support if standings look wrong."))
        }
        if failsDecode(tournament.podHistoryData, as: [PodSnapshot].self, field: "round history", tournament: tournament) {
            found.append(issue(tournament, field: "round history", hint: "Export a backup before editing past rounds."))
        }
        if failsDecode(tournament.rulesData, as: TournamentRules.self, field: "house rules", tournament: tournament) {
            found.append(issue(tournament, field: "house rules", hint: "Re-open house rules and save them again."))
        }

        return found
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
