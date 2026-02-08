import SwiftUI
import SwiftData

/// Root content view with TabView navigation.
/// Manages screen-driven navigation for flows.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var leagueStates: [LeagueState]
    
    @State private var showTournamentStandings = false
    @State private var tournamentsNavigationPath: [Tournament] = []
    /// ViewModel for New Tournament screen; persisted so adding a player doesn't recreate it and lose form state.
    @State private var newTournamentViewModel: NewTournamentViewModel?
    
    private var currentScreen: Screen {
        NavigationState.currentScreen(from: leagueStates)
    }
    
    private var shouldHideTabBar: Bool {
        NavigationState.shouldHideTabBar(from: leagueStates)
    }
    
    var body: some View {
        TabView {
            Tab("Tournaments", systemImage: "trophy.fill") {
                tournamentsStack
            }
            
            Tab("Players", systemImage: "person.crop.rectangle.stack") {
                playersStack
            }
            
            Tab("Stats", systemImage: "chart.bar") {
                statsStack
            }
            
            Tab("Achievements", systemImage: "star") {
                achievementsStack
            }
            
            Tab("Settings", systemImage: "gearshape.fill") {
                settingsStack
            }
        }
        .onChange(of: currentScreen) { _, newScreen in
            switch newScreen {
            case .newTournament, .confirmNewTournament:
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
                switch currentScreen {
                case .tournaments, .dashboard, .tournamentStandings:
                    TournamentsView(viewModel: TournamentsViewModel(context: modelContext), navigationPath: $tournamentsNavigationPath)
                case .newTournament, .confirmNewTournament:
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
                case .addPlayers:
                    AddPlayersView(viewModel: AddPlayersViewModel(context: modelContext))
                case .attendance:
                    AttendanceView(viewModel: AttendanceViewModel(context: modelContext))
                default:
                    TournamentsView(viewModel: TournamentsViewModel(context: modelContext), navigationPath: $tournamentsNavigationPath)
                }
            }
            .navigationDestination(for: Tournament.self) { tournament in
                TournamentDetailView(viewModel: TournamentDetailViewModel(context: modelContext, tournamentId: tournament.id))
            }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var playersStack: some View {
        NavigationStack {
            PlayersView(viewModel: PlayersViewModel(context: modelContext))
                .navigationDestination(for: Player.self) { player in
                    PlayerDetailView(viewModel: PlayerDetailViewModel(context: modelContext, player: player))
                }
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var statsStack: some View {
        NavigationStack {
            StatsView(viewModel: StatsViewModel(context: modelContext))
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var achievementsStack: some View {
        NavigationStack {
            AchievementsView(viewModel: AchievementsViewModel(context: modelContext))
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
    }
    
    @ViewBuilder
    private var settingsStack: some View {
        NavigationStack {
            SettingsView()
        }
        .toolbar(shouldHideTabBar ? .hidden : .visible, for: .tabBar)
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
        case .newTournament, .confirmNewTournament, .addPlayers, .attendance:
            return true
        default:
            return false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, Achievement.self, LeagueState.self, Tournament.self, GameResult.self], inMemory: true)
}
