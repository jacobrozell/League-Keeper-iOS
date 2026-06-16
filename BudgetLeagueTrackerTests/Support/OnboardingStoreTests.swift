import Foundation
import Testing
@testable import BudgetLeagueTracker

@Suite("OnboardingStore")
struct OnboardingStoreTests {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "OnboardingStoreTests.\(UUID().uuidString)")!
    }

    @Test("shouldPresentOnLaunch is true until completed")
    func shouldPresentUntilCompleted() {
        let defaults = makeDefaults()
        let store = OnboardingStore(userDefaults: defaults, isEnabled: true)

        #expect(store.shouldPresentOnLaunch)
        store.markCompleted()
        #expect(!store.shouldPresentOnLaunch)
    }

    @Test("disabled store never presents")
    func disabledNeverPresents() {
        let defaults = makeDefaults()
        let store = OnboardingStore(userDefaults: defaults, isEnabled: false)

        #expect(!store.shouldPresentOnLaunch)
    }

    @Test("clearCompleted resets completion")
    func clearCompleted() {
        let defaults = makeDefaults()
        let store = OnboardingStore(userDefaults: defaults, isEnabled: true)

        store.markCompleted()
        store.clearCompleted()
        #expect(store.shouldPresentOnLaunch)
    }
}
