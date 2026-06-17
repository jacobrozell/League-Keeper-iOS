import SwiftUI
import Charts

/// Player detail view - displays comprehensive player statistics with charts.
struct PlayerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: PlayerDetailViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                heroSection

                if viewModel.availableScopes.count > 1 {
                    scopeSection
                }

                statsSection

                if !viewModel.attendanceSummaries.isEmpty {
                    attendanceSection
                }

                if !viewModel.achievementGallery.isEmpty {
                    achievementSection
                }

                if viewModel.headToHeadOpponents.count > 0 {
                    headToHeadSection
                }

                if !viewModel.scopedRecentRounds.isEmpty {
                    recentRoundsSection
                }

                pointsBreakdownSection

                if viewModel.hasGameResults {
                    chartsSection
                }

                actionsSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .adaptiveContentWidth()
        .navigationTitle(viewModel.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    viewModel.showEditNameSheet = true
                }
                .accessibilityLabel("Edit player name")
            }
        }
        .sheet(isPresented: $viewModel.showEditNameSheet) {
            PlayerEditNameSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showRoundDetail) {
            if let detail = viewModel.selectedRoundDetail {
                PlayerRoundDetailSheet(detail: detail)
            }
        }
        .alert("Delete Player", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if viewModel.deletePlayer() {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete \(viewModel.displayName)? This action cannot be undone and will remove all their stats.")
        }
        .onAppear {
            viewModel.refresh()
        }
        .refreshable {
            viewModel.refresh()
        }
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroSection: some View {
        sectionContainer {
            PlayerIdentityCard(
                name: viewModel.displayName,
                playerId: viewModel.player.id,
                leagueRank: viewModel.leagueRank,
                winRateText: "\(viewModel.winRateString) win rate",
                lastPlayedText: viewModel.lastPlayedText,
                highlightText: viewModel.formHighlightText
            )
        }
    }

    // MARK: - Scope

    @ViewBuilder
    private var scopeSection: some View {
        sectionContainer {
            Group {
                if viewModel.availableScopes.count <= 3 {
                    Picker("Stats scope", selection: $viewModel.selectedScope) {
                        ForEach(viewModel.availableScopes) { scope in
                            Text(scope.title).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                } else {
                    Picker("Stats scope", selection: $viewModel.selectedScope) {
                        ForEach(viewModel.availableScopes) { scope in
                            Text(scope.title).tag(scope)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding()
            .accessibilityLabel("Stats scope")
        }
    }

    // MARK: - Stats Section

    @ViewBuilder
    private var statsSection: some View {
        sectionContainer {
            Text(viewModel.statsSectionTitle)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Total Points", value: "\(viewModel.displayTotalPoints)")
                StatCard(title: "Games Played", value: "\(viewModel.displayGamesPlayed)")
                StatCard(title: "Wins", value: "\(viewModel.displayWins)")
                if case .allTime = viewModel.selectedScope {
                    StatCard(title: "Tournaments", value: "\(viewModel.displayTournamentsPlayed)")
                }
                StatCard(title: "Win Rate", value: viewModel.winRateString)
                StatCard(title: "Avg Placement", value: viewModel.averagePlacementString)
            }
            .padding()
        }
    }

    // MARK: - Attendance Section

    @ViewBuilder
    private var attendanceSection: some View {
        sectionContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Attendance")
                    .font(.headline)

                HStack(spacing: 16) {
                    Gauge(value: viewModel.overallAttendanceFraction, in: 0...1) {
                        Text("Attendance")
                    } currentValueLabel: {
                        Text("\(Int((viewModel.overallAttendanceFraction * 100).rounded()))%")
                            .font(.caption.weight(.bold))
                    }
                    .gaugeStyle(.accessoryCircular)
                    .tint(AppConstants.AccessibleColors.activeStatus)
                    .frame(width: 64, height: 64)
                    .accessibilityLabel(viewModel.overallAttendanceText ?? "Attendance")

                    if let overall = viewModel.overallAttendanceText {
                        Text(overall)
                            .font(.subheadline.weight(.semibold))
                    }
                }

                ForEach(viewModel.attendanceSummaries) { summary in
                    HStack {
                        Text(summary.tournamentName)
                            .font(.subheadline)
                        Spacer()
                        Text(summary.summaryLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Achievements

    @ViewBuilder
    private var achievementSection: some View {
        sectionContainer {
            PlayerAchievementGallerySection(items: viewModel.achievementGallery)
                .padding()
        }
    }

    // MARK: - Head-to-Head

    @ViewBuilder
    private var headToHeadSection: some View {
        sectionContainer {
            PlayerHeadToHeadSection(
                opponents: viewModel.headToHeadOpponents,
                selectedOpponentId: $viewModel.headToHeadOpponentId,
                record: viewModel.headToHeadRecord,
                playerName: viewModel.displayName,
                opponentName: viewModel.headToHeadOpponentName,
                opponentLabel: viewModel.displayName(for:)
            )
            .padding()
        }
    }

    // MARK: - Recent Rounds Section

    @ViewBuilder
    private var recentRoundsSection: some View {
        sectionContainer {
            VStack(alignment: .leading, spacing: 0) {
                Text("Recent Rounds")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 4)

                ForEach(Array(viewModel.scopedRecentRounds.enumerated()), id: \.element.id) { index, round in
                    Button {
                        viewModel.selectRound(round)
                    } label: {
                        HStack {
                            PlayerRoundRow(round: round)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                                .padding(.trailing)
                        }
                    }
                    .buttonStyle(.plain)

                    if index < viewModel.scopedRecentRounds.count - 1 {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
    }

    // MARK: - Points Breakdown Section

    @ViewBuilder
    private var pointsBreakdownSection: some View {
        sectionContainer {
            VStack(alignment: .leading, spacing: 12) {
                Text("Points Breakdown")
                    .font(.headline)

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppConstants.AccessibleColors.placementAccent)
                                .frame(width: 12, height: 12)
                            Text("Placement")
                                .font(.subheadline)
                        }
                        Text("\(viewModel.displayPlacementPoints) pts")
                            .font(.title2.bold())
                            .foregroundStyle(AppConstants.AccessibleColors.placementAccent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(AppConstants.AccessibleColors.achievementAccent)
                                .frame(width: 12, height: 12)
                            Text("Achievement")
                                .font(.subheadline)
                        }
                        Text("\(viewModel.displayAchievementPoints) pts")
                            .font(.title2.bold())
                            .foregroundStyle(AppConstants.AccessibleColors.achievementAccent)
                    }

                    Spacer()
                }

                HStack {
                    Text("Points per Game")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(viewModel.pointsPerGameString)
                        .font(.subheadline.bold())
                }
            }
            .padding()
        }
    }

    // MARK: - Charts Section

    @ViewBuilder
    private var chartsSection: some View {
        sectionContainer {
            PieChartView.placementDistribution(
                title: "Placement Distribution",
                data: viewModel.placementDistribution,
                style: .donut,
                height: 160
            )
        }

        if !viewModel.performanceTrend.isEmpty {
            sectionContainer {
                LineChartView.performanceTrend(
                    title: "Performance Over Time",
                    data: viewModel.performanceTrend,
                    showArea: true,
                    height: 180
                )
            }
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionsSection: some View {
        sectionContainer {
            Button(role: .destructive) {
                viewModel.confirmDelete()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Player")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// MARK: - Stat Card Component

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.primary)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        PlayerDetailView(
            viewModel: PlayerDetailViewModel(
                context: PreviewContainer.shared.mainContext,
                player: Player(name: "Test Player")
            )
        )
    }
}
