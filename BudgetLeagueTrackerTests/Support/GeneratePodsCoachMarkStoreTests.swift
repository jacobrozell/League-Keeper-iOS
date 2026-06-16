import Foundation
import Testing
@testable import BudgetLeagueTracker

@Suite("GeneratePodsCoachMarkStore")
struct GeneratePodsCoachMarkStoreTests {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "GeneratePodsCoachMarkStoreTests.\(UUID().uuidString)")!
    }

    @Test("shows coach mark until dismissed")
    func showsUntilSeen() {
        let defaults = makeDefaults()
        let store = GeneratePodsCoachMarkStore(userDefaults: defaults, isEnabled: true)

        #expect(store.shouldShowCoachMark)
        store.markSeen()
        #expect(!store.shouldShowCoachMark)
    }

    @Test("disabled store never shows")
    func disabledNeverShows() {
        let defaults = makeDefaults()
        let store = GeneratePodsCoachMarkStore(userDefaults: defaults, isEnabled: false)

        #expect(!store.shouldShowCoachMark)
    }
}
