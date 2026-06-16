import SwiftUI
import SwiftData

/// Legacy Dashboard view - redirects to TournamentsView.
/// Kept for backwards compatibility.
struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    @State private var navigationPath: [Tournament] = []
    
    var body: some View {
        TournamentsView(viewModel: TournamentsViewModel(context: viewModel.context), navigationPath: $navigationPath)
    }
}

#Preview {
    NavigationStack {
        DashboardView(viewModel: DashboardViewModel(context: PreviewContainer.shared.mainContext))
    }
}

// MARK: - Preview Helper

/// A shared preview container for SwiftUI previews.
@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let container = try! LeagueKeeperModelContainer.make(isStoredInMemoryOnly: true)
        
        // Bootstrap default data
        let context = container.mainContext
        context.insert(LeagueState())
        context.insert(Achievement(
            name: AppConstants.DefaultAchievement.name,
            points: AppConstants.DefaultAchievement.points,
            alwaysOn: AppConstants.DefaultAchievement.alwaysOn
        ))
        
        return container
    }()
}
