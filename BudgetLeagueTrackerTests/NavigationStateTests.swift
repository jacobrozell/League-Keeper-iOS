import Testing
@testable import BudgetLeagueTracker

/// Unit tests for NavigationState (tab/routing logic extracted from ContentView).
@Suite("NavigationState Tests")
struct NavigationStateTests {

    @Test("currentScreen returns first state screen")
    func currentScreenFromState() {
        let state = LeagueState()
        state.screen = .pods
        let result = NavigationState.currentScreen(from: [state])
        #expect(result == .pods)
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

    @Test("shouldHideTabBar false for pods")
    func shouldHideTabBarPods() {
        let state = LeagueState()
        state.screen = .pods
        #expect(NavigationState.shouldHideTabBar(from: [state]) == false)
    }
}
