import Testing
@testable import BudgetLeagueTracker

@Suite("AchievementTemplates")
struct AchievementTemplatesTests {
    @Test("Generic and card game catalogs are non-empty and unique within each library")
    func catalogCountsAndUniqueness() {
        for library in AchievementTemplateLibrary.allCases {
            let templates = AchievementTemplates.templates(for: library)
            #expect(!templates.isEmpty)
            let names = templates.map(\.name)
            #expect(Set(names).count == names.count)
        }
    }

    @Test("First Blood is only in the card game catalog")
    func firstBloodInCardGameOnly() {
        let genericNames = AchievementTemplates.templates(for: .generic).map(\.name)
        let cardGameNames = AchievementTemplates.templates(for: .cardGame).map(\.name)

        #expect(!genericNames.contains("First Blood"))
        #expect(cardGameNames.contains("First Blood"))
    }

    @Test("Table Captain appears in generic catalog")
    func tableCaptainInGeneric() {
        let genericNames = AchievementTemplates.templates(for: .generic).map(\.name)
        #expect(genericNames.contains("Table Captain"))
    }
}
