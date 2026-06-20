import SwiftUI
import SwiftData

/// Root content view with TabView navigation.
/// Manages screen-driven navigation for flows.
struct ContentView: View {
    private enum AppTab: Hashable {
        case tournaments
        case players
        case stats
        case achievements
        case settings
    }

    @Environment(\.modelContext) private var modelContext
    @Query private var leagueStates: [LeagueState]
    @Query private var players: [Player]
    @Query private var tournaments: [Tournament]

    private let onboardingStore = OnboardingStore()
    private let attendanceCoachMarkStore = AttendanceCoachMarkStore()
    private let generatePodsCoachMarkStore = GeneratePodsCoachMarkStore()

    private var isAccessibilityUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("UI-Testing-Accessibility")
    }

    @State private var showTournamentStandings = false
    @State private var showOnboarding = false
    @State private var onboardingSampleError: String?
    @State private var selectedTab: AppTab = .tournaments
    @State private var tournamentsNavigationPath: [Tournament] = []
    @State private var tabViewModels: TabViewModels?
    @State private var attendanceViewModel: AttendanceViewModel?
    /// ViewModel for New Tournament screen; persisted so adding a player doesn't recreate it and lose form state.
    @State private var newTournamentViewModel: NewTournamentViewModel?
    
    private var currentScreen: Screen {
        NavigationState.currentScreen(from: leagueStates)
    }
    
    private var shouldHideTabBar: Bool {
        NavigationState.shouldHideTabBar(from: leagueStates)
    }

    private var isInTournamentDetail: Bool {
        !tournamentsNavigationPath.isEmpty
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.tournaments) {
                tournamentsStack
            } label: {
                Label("Tournaments", systemImage: "trophy.fill")
                    .accessibilityIdentifier("tabTournaments")
            }

            Tab(value: AppTab.players) {
                playersStack
            } label: {
                Label("Players", systemImage: "person.crop.rectangle.stack")
                    .accessibilityIdentifier("tabPlayers")
            }

            Tab(value: AppTab.stats) {
                statsStack
            } label: {
                Label("Stats", systemImage: "chart.bar")
                    .accessibilityIdentifier("tabStats")
            }

            Tab(value: AppTab.achievements) {
                achievementsStack
            } label: {
                Label("Achievements", systemImage: "star")
                    .accessibilityIdentifier("tabAchievements")
            }

            Tab(value: AppTab.settings) {
                settingsStack
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
                    .accessibilityIdentifier("tabSettings")
            }
        }
        .tint(Color("AccentColor"))
        .brandedAdaptiveScreen()
        .modifier(OptionalDynamicTypeSize(isAccessibilityUITest: isAccessibilityUITest))
        .onAppear {
            UITestBootstrap.applyIfNeeded(context: modelContext)
            if tabViewModels == nil {
                tabViewModels = TabViewModels(context: modelContext)
            }
            if attendanceViewModel == nil {
                attendanceViewModel = AttendanceViewModel(context: modelContext)
            }
            if let snapshotTab = UITestSnapshot.consumePendingMainTab() {
                selectedTab = appTab(for: snapshotTab)
            }
            UITestBootstrap.openPendingTournamentDetailIfNeeded(
                context: modelContext,
                navigationPath: &tournamentsNavigationPath
            )
            checkOnboarding()
        }
        .onChange(of: players.count) { _, _ in checkOnboarding() }
        .onChange(of: tournaments.count) { _, _ in checkOnboarding() }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView { completeOnboarding($0) }
        }
        .alert("Sample league", isPresented: Binding(
            get: { onboardingSampleError != nil },
            set: { if !$0 { onboardingSampleError = nil } }
        )) {
            Button("OK", role: .cancel) { onboardingSampleError = nil }
        } message: {
            if let onboardingSampleError {
                Text(onboardingSampleError)
            }
        }
        .onChange(of: currentScreen) { _, newScreen in
            switch newScreen {
            case .newTournament:
                if newTournamentViewModel == nil {
                    newTournamentViewModel = NewTournamentViewModel(context: modelContext)
                }
            default:
                newTournamentViewModel = nil
            }
            // Only show tournament standings modal at tournament end
            if newScreen == .tournamentStandings {
                showTournamentStandings = true
            }
        }
        .fullScreenCover(isPresented: $showTournamentStandings) {
            TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: modelContext))
        }
    }
    
    // MARK: - Tab Stacks
    
    @ViewBuilder
    private var tournamentsStack: some View {
        NavigationStack(path: $tournamentsNavigationPath) {
            Group {
                if let tabViewModels {
                    switch currentScreen {
                    case .tournaments, .tournamentStandings:
                        TournamentsView(
                            viewModel: tabViewModels.tournaments,
                            navigationPath: $tournamentsNavigationPath
                        )
                    case .newTournament:
                        if let vm = newTournamentViewModel {
                            NewTournamentView(viewModel: vm)
                        } else {
                            ProgressView()
                                .onAppear {
                                    if newTournamentViewModel == nil {
                                        newTournamentViewModel = NewTournamentViewModel(context: modelContext)
                                    }
                                }
                        }
                    case .attendance:
                        if let attendanceViewModel {
                            AttendanceView(
                                viewModel: attendanceViewModel,
                                navigationStyle: .standalone,
                                onConfirm: { _, _ in
                                    completeStandaloneAttendance()
                                }
                            )
                        } else {
                            ProgressView()
                        }
                    default:
                        TournamentsView(
                            viewModel: tabViewModels.tournaments,
                            navigationPath: $tournamentsNavigationPath
                        )
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationDestination(for: Tournament.self) { tournament in
                TournamentDetailRoute(
                    context: modelContext,
                    tournamentId: tournament.id,
                    showsAttendanceCoachMark: attendanceCoachMarkStore.shouldShowCoachMark,
                    onDismissAttendanceCoachMark: { attendanceCoachMarkStore.markSeen() },
                    showsGeneratePodsCoachMark: generatePodsCoachMarkStore.shouldShowCoachMark,
                    onDismissGeneratePodsCoachMark: { generatePodsCoachMarkStore.markSeen() }
                )
            }
        }
        .toolbar(shouldHideTabBar || isInTournamentDetail ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var playersStack: some View {
        NavigationStack {
            if let tabViewModels {
                PlayersView(viewModel: tabViewModels.players)
                    .navigationDestination(for: Player.self) { player in
                        PlayerDetailView(viewModel: PlayerDetailViewModel(context: modelContext, player: player))
                    }
            } else {
                ProgressView()
            }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var statsStack: some View {
        NavigationStack {
            if let tabViewModels {
                StatsView(viewModel: tabViewModels.stats)
                    .navigationDestination(for: Player.self) { player in
                        PlayerDetailView(viewModel: PlayerDetailViewModel(context: modelContext, player: player))
                    }
            } else {
                ProgressView()
            }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var achievementsStack: some View {
        NavigationStack {
            if let tabViewModels {
                AchievementsView(viewModel: tabViewModels.achievements)
            } else {
                ProgressView()
            }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var settingsStack: some View {
        NavigationStack {
            SettingsView(onViewOnboarding: { showOnboarding = true })
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }

    private func checkOnboarding() {
        guard onboardingStore.shouldPresentOnLaunch else { return }
        if !players.isEmpty || !tournaments.isEmpty {
            onboardingStore.markCompleted()
            return
        }
        guard !showOnboarding else { return }
        showOnboarding = true
    }

    private func completeOnboarding(_ action: OnboardingView.Completion) {
        onboardingStore.markCompleted()
        showOnboarding = false

        switch action {
        case .dismiss:
            break
        case .loadSample:
            do {
                let result = try DemoLeagueLoader.load(into: modelContext)
                selectedTab = .tournaments
                openTournamentDetail(tournamentId: result.tournamentId)
            } catch {
                onboardingSampleError = error.localizedDescription
            }
        case .createTournament:
            LeagueEngine.setScreen(context: modelContext, screen: .newTournament)
        }
    }

    private func openTournamentDetail(tournamentId: String) {
        var descriptor = FetchDescriptor<Tournament>(
            predicate: #Predicate { $0.id == tournamentId }
        )
        descriptor.fetchLimit = 1
        guard let tournament = try? modelContext.fetch(descriptor).first else { return }
        tournamentsNavigationPath = [tournament]
    }

    private func completeStandaloneAttendance() {
        LeagueEngine.setScreen(context: modelContext, screen: .tournaments)
        attendanceViewModel?.refresh()
        if let tournamentId = LeagueEngine.fetchLeagueState(context: modelContext)?.activeTournamentId {
            openTournamentDetail(tournamentId: tournamentId)
        }
    }

    private func appTab(for tab: ContentViewSnapshotTab) -> AppTab {
        switch tab {
        case .stats: return .stats
        case .achievements: return .achievements
        case .settings: return .settings
        }
    }
}

// MARK: - NavigationState (testable routing logic)

/// Pure logic for tab/routing derived from LeagueState. Unit-testable.
enum NavigationState {
    /// Returns the current screen from the first league state, or `.tournaments` if empty.
    static func currentScreen(from leagueStates: [LeagueState]) -> Screen {
        leagueStates.first?.screen ?? .tournaments
    }
    
    /// Whether the tab bar should be hidden for the current screen.
    static func shouldHideTabBar(from leagueStates: [LeagueState]) -> Bool {
        switch currentScreen(from: leagueStates) {
        case .newTournament, .attendance:
            return true
        default:
            return false
        }
    }
}

/// Applies AXXXL Dynamic Type during accessibility UI tests (matches MiniMuster AppShell).
private struct OptionalDynamicTypeSize: ViewModifier {
    let isAccessibilityUITest: Bool

    func body(content: Content) -> some View {
        if isAccessibilityUITest {
            content.dynamicTypeSize(.accessibility5)
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Achievement.self, LeagueState.self, Tournament.self, GameResult.self], inMemory: true)
}
