import Testing
@testable import BudgetLeagueTracker

@Suite("NavigationState Tests")
struct NavigationStateTests {

    @Test("currentScreen migrates legacy pods to tournaments")
    func currentScreenMigratesLegacyPods() {
        let state = LeagueState(currentScreen: "pods")
        let result = NavigationState.currentScreen(from: [state])
        #expect(result == .tournaments)
    }

    @Test("currentScreen returns tournaments when empty")
    func currentScreenEmpty() {
        #expect(NavigationState.currentScreen(from: []) == .tournaments)
    }

    @Test("shouldHideTabBar true for attendance")
    func shouldHideTabBarAttendance() {
        let state = LeagueState()
        state.screen = .attendance
        #expect(NavigationState.shouldHideTabBar(from: [state]) == true)
    }

    @Test("shouldHideTabBar true for newTournament")
    func shouldHideTabBarNewTournament() {
        let state = LeagueState()
        state.screen = .newTournament
        #expect(NavigationState.shouldHideTabBar(from: [state]) == true)
    }

    @Test("shouldHideTabBar false for tournaments")
    func shouldHideTabBarTournaments() {
        let state = LeagueState()
        state.screen = .tournaments
        #expect(NavigationState.shouldHideTabBar(from: [state]) == false)
    }

    @Test("shouldHideTabBar false for migrated legacy pods screen")
    func shouldHideTabBarLegacyPods() {
        let state = LeagueState(currentScreen: "pods")
        #expect(NavigationState.shouldHideTabBar(from: [state]) == false)
    }
}
