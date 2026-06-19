import SwiftData

/// Stable tab-scoped ViewModels so TabView re-renders do not recreate state.
@Observable
@MainActor
final class TabViewModels {
    let tournaments: TournamentsViewModel
    let players: PlayersViewModel
    let stats: StatsViewModel
    let achievements: AchievementsViewModel

    init(context: ModelContext) {
        tournaments = TournamentsViewModel(context: context)
        players = PlayersViewModel(context: context)
        stats = StatsViewModel(context: context)
        achievements = AchievementsViewModel(context: context)
    }
}
