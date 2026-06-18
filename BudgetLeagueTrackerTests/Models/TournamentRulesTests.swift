import Testing
@testable import BudgetLeagueTracker

@Suite("TournamentRules")
struct TournamentRulesTests {

    @Test("Client default matches Budget Commander league rules")
    func clientDefaultMatchesBudgetCommander() {
        let rules = AppConstants.TournamentRulesDefaults.defaultRules

        #expect(rules.entryFeeCents == 1_000)
        #expect(rules.signupBoosterPrize)
        #expect(rules.podWinnerBoosterPrize)
        #expect(rules.deckBudgetCents == 7_500)
        #expect(rules.pricingSource == .lowestOfTCGPlayerOrMoxfield)
        #expect(rules.maxCardPriceCents == 1_000)
        #expect(rules.commanderExcludedFromBudget)
        #expect(rules.basicLandsExcludedFromBudget)
        #expect(rules.commanderPriceLimitCents == nil)
        #expect(rules.targetBracket == 2)
        #expect(rules.playstyleNotes.contains("Bracket 2"))
    }

    @Test("Summary includes key rule lines")
    func summaryIncludesKeyLines() {
        let lines = AppConstants.TournamentRulesDefaults.defaultRules.summaryLines()

        #expect(lines.contains { $0.contains("$10") })
        #expect(lines.contains { $0.contains("booster at sign-up") })
        #expect(lines.contains { $0.contains("booster per pod winner") })
        #expect(lines.contains { $0.contains("$75") })
        #expect(lines.contains { $0.contains("No commander price limit") })
        #expect(lines.contains { $0.contains("Target Bracket 2") })
    }

    @Test("Compact summary highlights key defaults")
    func compactSummaryHighlightsDefaults() {
        let summary = AppConstants.TournamentRulesDefaults.defaultRules.compactSummary()

        #expect(summary.contains("$10"))
        #expect(summary.contains("$75 budget"))
        #expect(summary.contains("Bracket 2"))
    }

    @Test("Free entry formats correctly")
    func freeEntryFormatsCorrectly() {
        var rules = AppConstants.TournamentRulesDefaults.defaultRules
        rules.entryFeeCents = 0

        #expect(rules.summaryLines().contains { $0 == "Free entry" })
    }

    @Test("Empty playstyle omits section from summary")
    func emptyPlaystyleOmitsSection() {
        var rules = AppConstants.TournamentRulesDefaults.defaultRules
        rules.targetBracket = nil
        rules.playstyleNotes = ""

        let sections = rules.summarySections()
        #expect(!sections.contains { $0.title == "Playstyle" })
    }

    @Test("No prizes line appears when boosters disabled")
    func noPrizesLineWhenBoostersDisabled() {
        var rules = AppConstants.TournamentRulesDefaults.defaultRules
        rules.signupBoosterPrize = false
        rules.podWinnerBoosterPrize = false

        let lines = rules.summarySections().first { $0.title == "Entry & Prizes" }?.lines ?? []
        #expect(lines.contains("No prizes configured"))
    }

    @Test("Dollar formatting handles whole and fractional amounts")
    func dollarFormatting() {
        #expect(TournamentRules.formatDollars(1_000) == "$10")
        #expect(TournamentRules.formatDollars(1_050) == "$10.50")
        #expect(TournamentRules.formatDollars(0) == "$0")
    }
}
