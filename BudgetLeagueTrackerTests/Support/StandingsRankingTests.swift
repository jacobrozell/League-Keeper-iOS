import Testing
@testable import BudgetLeagueTracker

@Suite("StandingsRanking")
@MainActor
struct StandingsRankingTests {
    @Test("Higher points rank above lower points")
    func pointsOrder() {
        let high = TestFixtures.player(name: "Zara")
        let low = TestFixtures.player(name: "Amy")
        #expect(StandingsRanking.ranksHigher(points: 10, player: high, than: 5, player: low))
        #expect(!StandingsRanking.ranksHigher(points: 5, player: low, than: 10, player: high))
    }

    @Test("Equal points tiebreak by name then id")
    func tiebreakByName() {
        let amy = TestFixtures.player(name: "Amy")
        let zoe = TestFixtures.player(name: "Zoe")
        #expect(StandingsRanking.ranksHigher(points: 4, player: amy, than: 4, player: zoe))
        #expect(!StandingsRanking.ranksHigher(points: 4, player: zoe, than: 4, player: amy))
    }

    @Test("Winner selection matches first ranked player")
    func winnerPlayer() {
        let amy = TestFixtures.player(name: "Amy")
        let zoe = TestFixtures.player(name: "Zoe")
        let points = [amy.id: 4, zoe.id: 4]
        let winner = StandingsRanking.winnerPlayer(from: points, among: [zoe, amy])
        #expect(winner?.name == "Amy")
    }
}
