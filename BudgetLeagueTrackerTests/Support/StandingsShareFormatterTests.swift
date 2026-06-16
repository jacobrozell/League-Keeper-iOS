import Foundation
import Testing
@testable import BudgetLeagueTracker

@Suite("StandingsShareFormatter")
struct StandingsShareFormatterTests {
    @Test("weekly standings formats ranked rows")
    func weeklyFormat() {
        let text = StandingsShareFormatter.weeklyStandings(
            tournamentName: "Friday Night",
            week: 2,
            standings: [
                .init(rank: 1, name: "Alex", totalPoints: 12, placementPoints: 8, achievementPoints: 4),
                .init(rank: 2, name: "Blake", totalPoints: 9, placementPoints: 7, achievementPoints: 2)
            ]
        )

        #expect(text.contains("Friday Night"))
        #expect(text.contains("Week 2 standings"))
        #expect(text.contains("1. Alex — 12 pts"))
        #expect(text.contains("2. Blake — 9 pts"))
    }

    @Test("weekly standings handles empty list")
    func weeklyEmpty() {
        let text = StandingsShareFormatter.weeklyStandings(
            tournamentName: "League",
            week: 1,
            standings: []
        )

        #expect(text.contains("No scores recorded"))
    }

    @Test("final standings formats wins")
    func finalFormat() {
        let text = StandingsShareFormatter.finalStandings(
            tournamentName: "Summer",
            standings: [
                .init(rank: 1, name: "Alex", totalPoints: 40, placementPoints: 30, achievementPoints: 10, wins: 5)
            ]
        )

        #expect(text.contains("Final standings"))
        #expect(text.contains("W: 5"))
    }
}
