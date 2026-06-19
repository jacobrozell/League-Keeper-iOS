import SwiftUI
import Charts

/// Achievements view - manage achievements (add, remove, toggle always-on) with stats.
struct AchievementsView: View {
    @Bindable var viewModel: AchievementsViewModel
    @Environment(\.palette) private var palette
    @State private var toastMessage: String?
    
    var body: some View {
        Group {
            if viewModel.hasAchievements {
                achievementsContent
            } else {
                emptyState
            }
        }
        .navigationTitle("Achievements")
        .adaptiveContentWidth()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showNewAchievement()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add achievement")
                .accessibilityIdentifier("Add achievement")
            }
        }
        .sheet(isPresented: $viewModel.isShowingTemplatePicker) {
            AchievementTemplatePickerView(
                onSelectTemplate: { template in
                    viewModel.selectTemplate(template)
                },
                onCancel: {
                    viewModel.isShowingTemplatePicker = false
                }
            )
        }
        .sheet(item: $viewModel.presentedFormMode) { mode in
            AchievementFormView(viewModel: viewModel.makeFormViewModel(for: mode))
        }
        .onAppear {
            viewModel.refresh()
        }
        .onPersistenceError(viewModel.persistenceErrorMessage, showToast: showToast, clearError: viewModel.clearPersistenceError)
        .toastOverlay(toastMessage)
    }

    private func showToast(_ message: String) {
        ToastPresentation.show(message, binding: $toastMessage)
    }
    
    // MARK: - Achievements Content
    
    @ViewBuilder
    private var achievementsContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                sectionContainer {
                    AchievementBalanceSummaryView(summary: viewModel.balanceSummary)
                        .padding()
                }

                // Stats Summary Section
                if viewModel.hasGameResults {
                    statsSummarySection
                    
                    // Achievement Distribution Chart
                    if !viewModel.achievementDistribution.isEmpty {
                        distributionChartSection
                    }
                }
                
                // Achievements List with Stats
                achievementsListSection
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Stats Summary Section
    
    @ViewBuilder
    private var statsSummarySection: some View {
        let summary = viewModel.statsSummary
        
        sectionContainer {
            VStack(alignment: .leading, spacing: 12) {
                Label("Stats Summary", systemImage: "chart.bar.fill")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    // Total Earned
                    statCard(
                        title: "Total Earned",
                        value: "\(summary.totalEarned)",
                        icon: "trophy.fill",
                        color: AppConstants.AccessibleColors.statOrange
                    )
                    
                    // Unique Achievements
                    statCard(
                        title: "Unique Earned",
                        value: "\(summary.uniqueAchievementsEarned)/\(viewModel.achievements.count)",
                        icon: "star.fill",
                        color: AppConstants.AccessibleColors.statYellow
                    )
                }
                
                // Most Popular & Rarest
                if summary.mostPopularName != nil || summary.rarestName != nil {
                    Divider()
                    
                    HStack(spacing: 16) {
                        if let popular = summary.mostPopularName {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Most Popular")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(popular)
                                    .font(.subheadline.bold())
                                Text("\(summary.mostPopularCount) times")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if let rarest = summary.rarestName, summary.rarestCount > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rarest")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(rarest)
                                    .font(.subheadline.bold())
                                Text("\(summary.rarestCount) times")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.caption)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: palette.surface2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Distribution Chart Section
    
    @ViewBuilder
    private var distributionChartSection: some View {
        sectionContainer {
            PieChartView.achievementDistribution(
                title: "Achievement Distribution",
                data: viewModel.achievementDistribution,
                style: .pie,
                height: 180
            )
        }
    }
    
    // MARK: - Achievements List Section
    
    @ViewBuilder
    private var achievementsListSection: some View {
        sectionContainer {
            VStack(alignment: .leading, spacing: 0) {
                Text("Achievements")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                ForEach(viewModel.achievements, id: \.id) { achievement in
                    achievementRow(for: achievement)
                    
                    if achievement.id != viewModel.achievements.last?.id {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func achievementRow(for achievement: Achievement) -> some View {
        let totalEarned = viewModel.totalTimesEarned(for: achievement)
        let topEarners = viewModel.topEarners(for: achievement, limit: 3)
        
        VStack(alignment: .leading, spacing: 8) {
            AchievementListRow(
                achievement: achievement,
                onEdit: { viewModel.editAchievement(achievement) },
                onDuplicate: { viewModel.duplicateAchievement(achievement) },
                onToggleAlwaysOn: { viewModel.toggleAlwaysOn(achievement) },
                onRemove: { viewModel.removeAchievement(achievement) }
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 4)

            // Stats Row (only if there are game results)
            if viewModel.hasGameResults {
                HStack {
                    Label("Earned \(totalEarned) times", systemImage: "trophy")
                        .font(.caption)
                        .foregroundStyle(totalEarned > 0 ? .secondary : .tertiary)

                    Spacer()
                }
                .padding(.horizontal)
                
                // Top Earners (if any)
                if !topEarners.isEmpty {
                    HStack(spacing: 4) {
                        Text("Top:")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        ForEach(Array(topEarners.enumerated()), id: \.offset) { index, earner in
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(earnerColor(for: index))
                                    .frame(width: 6, height: 6)
                                Text("\(earner.playerName) (\(earner.count))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            if index < topEarners.count - 1 {
                                Text("·")
                                    .font(.caption2)
                                    .foregroundStyle(.quaternary)
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    private func earnerColor(for index: Int) -> Color {
        switch index {
        case 0: return AppConstants.AccessibleColors.statYellow
        case 1: return AppConstants.AccessibleColors.semanticGray
        case 2: return AppConstants.AccessibleColors.statOrange
        default: return .secondary
        }
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            EmptyStateView(
                message: "No achievements yet",
                hint: "Tap the + button to create your first achievement."
            )
            
            Spacer()
            
            PrimaryActionButton(title: "Add Achievement") {
                viewModel.showNewAchievement()
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .adaptiveEmptyStateLayout()
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func sectionContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(Color(hex: palette.surface))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 4)
    }
}

#Preview {
    NavigationStack {
        AchievementsView(viewModel: AchievementsViewModel(context: PreviewContainer.shared.mainContext))
    }
}
