import Testing
@testable import BudgetLeagueTracker

@Suite("PlayerDisambiguation Tests")
struct PlayerDisambiguationTests {

    @Test("Returns plain name when unique")
    func uniqueName() {
        let player = Player(name: "Devan")
        #expect(PlayerDisambiguation.displayName(for: player, among: [player]) == "Devan")
    }

    @Test("Numbers duplicate names by stable id order")
    func numberedDuplicates() {
        let first = Player(id: "a", name: "Devan")
        let second = Player(id: "b", name: "Devan")

        #expect(PlayerDisambiguation.displayName(for: first, among: [first, second]) == "Devan (1)")
        #expect(PlayerDisambiguation.displayName(for: second, among: [first, second]) == "Devan (2)")
    }

    @Test("Uses nickname when provided")
    func nicknameTakesPrecedence() {
        let first = Player(id: "a", name: "Devan", nameNote: "Smith")
        let second = Player(id: "b", name: "Devan")

        #expect(PlayerDisambiguation.displayName(for: first, among: [first, second]) == "Devan (Smith)")
        #expect(PlayerDisambiguation.displayName(for: second, among: [first, second]) == "Devan (2)")
    }

    @Test("Case-insensitive duplicate detection")
    func caseInsensitivePeers() {
        let first = Player(id: "a", name: "devan")
        let second = Player(id: "b", name: "Devan")

        #expect(PlayerDisambiguation.displayName(for: first, among: [first, second]) == "devan (1)")
        #expect(PlayerDisambiguation.displayName(for: second, among: [first, second]) == "Devan (2)")
    }

    @Test("Sanitized note trims and caps length")
    func sanitizedNote() {
        #expect(PlayerDisambiguation.sanitizedNote(nil) == nil)
        #expect(PlayerDisambiguation.sanitizedNote("  ") == nil)
        #expect(PlayerDisambiguation.sanitizedNote("  Smith  ") == "Smith")
    }
}
