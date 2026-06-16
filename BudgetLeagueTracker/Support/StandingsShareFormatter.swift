import Foundation

/// Plain-text standings for the system share sheet (Discord, Messages, etc.).
enum StandingsShareFormatter {
    struct WeeklyStanding {
        let rank: Int
        let name: String
        let totalPoints: Int
        let placementPoints: Int
        let achievementPoints: Int
    }

    struct TournamentStanding {
        let rank: Int
        let name: String
        let totalPoints: Int
        let placementPoints: Int
        let achievementPoints: Int
        let wins: Int
    }

    static func weeklyStandings(
        tournamentName: String,
        week: Int,
        standings: [WeeklyStanding]
    ) -> String {
        var lines = [
            "\(AppInfo.displayName) — \(tournamentName)",
            "Week \(week) standings",
            ""
        ]
        if standings.isEmpty {
            lines.append("No scores recorded this week.")
        } else {
            for row in standings {
                lines.append(
                    "\(row.rank). \(row.name) — \(row.totalPoints) pts (P: \(row.placementPoints), A: \(row.achievementPoints))"
                )
            }
        }
        return lines.joined(separator: "\n")
    }

    static func finalStandings(
        tournamentName: String,
        standings: [TournamentStanding]
    ) -> String {
        var lines = [
            "\(AppInfo.displayName) — \(tournamentName)",
            "Final standings",
            ""
        ]
        if standings.isEmpty {
            lines.append("No standings to display.")
        } else {
            for row in standings {
                lines.append(
                    "\(row.rank). \(row.name) — \(row.totalPoints) pts (P: \(row.placementPoints), A: \(row.achievementPoints), W: \(row.wins))"
                )
            }
        }
        return lines.joined(separator: "\n")
    }
}
