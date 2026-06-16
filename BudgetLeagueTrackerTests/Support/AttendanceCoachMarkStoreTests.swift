import Foundation
import Testing
@testable import BudgetLeagueTracker

@Suite("AttendanceCoachMarkStore")
struct AttendanceCoachMarkStoreTests {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "AttendanceCoachMarkStoreTests.\(UUID().uuidString)")!
    }

    @Test("shows coach mark until dismissed")
    func showsUntilSeen() {
        let defaults = makeDefaults()
        let store = AttendanceCoachMarkStore(userDefaults: defaults, isEnabled: true)

        #expect(store.shouldShowCoachMark)
        store.markSeen()
        #expect(!store.shouldShowCoachMark)
    }

    @Test("disabled store never shows")
    func disabledNeverShows() {
        let defaults = makeDefaults()
        let store = AttendanceCoachMarkStore(userDefaults: defaults, isEnabled: false)

        #expect(!store.shouldShowCoachMark)
    }

    @Test("clearSeen resets state")
    func clearSeen() {
        let defaults = makeDefaults()
        let store = AttendanceCoachMarkStore(userDefaults: defaults, isEnabled: true)

        store.markSeen()
        store.clearSeen()
        #expect(store.shouldShowCoachMark)
    }
}
