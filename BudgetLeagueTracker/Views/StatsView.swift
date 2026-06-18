import SwiftUI
import Charts

/// Stats view - displays weekly standings, tournament standings, player statistics, and charts.
struct StatsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Bindable var viewModel: StatsViewModel
    
    var body: some View {
        Group {
            if viewModel.hasPlayers {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        statsSectionPicker
                            .background(.bar)

                        segmentScrollContent
                    }
                }
            } else {
                VStack(spacing: 24) {
                    Spacer()

                    EmptyStateView(
                        message: "No stats yet",
                        hint: "Create a tournament and play some games to see stats.",
                        systemImage: "chart.bar"
                    )

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .adaptiveEmptyStateLayout()
            }
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.large)
        .adaptiveContentWidth()
        .onAppear {
            viewModel.refresh()
        }
    }
    
    @ViewBuilder
    private var statsSectionPicker: some View {
        let chromePadding = AdaptiveLayout.chromeVerticalPadding(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        Group {
            if AdaptiveLayout.usesMenuSectionPicker(
                dynamicType: dynamicTypeSize,
                verticalSizeClass: verticalSizeClass
            ) {
                HStack {
                    Text("Section")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Picker("Section", selection: $viewModel.activeSegment) {
                        ForEach(viewModel.visibleSegments, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("statsSectionPicker")
                    .accessibilitySelectedSection("Section", value: viewModel.activeSegment.rawValue)
                }
                .padding(.horizontal)
                .padding(.vertical, chromePadding)
            } else {
                Picker("Section", selection: $viewModel.activeSegment) {
                    ForEach(viewModel.visibleSegments, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("statsSectionPicker")
                .accessibilitySelectedSection("Section", value: viewModel.activeSegment.rawValue)
                .padding(.horizontal)
                .padding(.vertical, chromePadding)
            }
        }
        .onChange(of: viewModel.visibleSegments) { _, newSegments in
            if !newSegments.contains(viewModel.activeSegment) {
                viewModel.activeSegment = .standings
            }
        }
    }

    @ViewBuilder
    private var segmentScrollContent: some View {
        switch viewModel.activeSegment {
        case .weekly:
            weeklySection
        case .standings:
            standingsSection
        case .charts:
            chartsSectionContent
        case .players:
            playersSection
        }
    }
    
    @ViewBuilder
    private var weeklySection: some View {
        if viewModel.weeklyStandings.isEmpty {
            BrandedSectionCard {
                EmptyStateView(
                    message: "No scores yet this week",
                    hint: "Finish a table to see weekly standings here.",
                    systemImage: "list.number"
                )
                .padding()
            }
        } else {
            weeklyStandingsList
        }
    }

    @ViewBuilder
    private var weeklyStandingsList: some View {
        BrandedSectionCard {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if !viewModel.tournamentName.isEmpty {
                        Text(viewModel.tournamentName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Week \(viewModel.currentWeek) Standings")
                        .font(.system(.headline, design: .serif))
                }
                Spacer()
                ShareLink(item: viewModel.weeklyStandingsShareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                }
                .accessibilityLabel("Share week standings")
            }
            .padding(.horizontal)
            .padding(.top)
            
            ForEach(Array(viewModel.weeklyStandings.enumerated()), id: \.element.player.id) { index, item in
                StandingsRow(
                    rank: index + 1,
                    name: viewModel.displayName(for: item.player),
                    totalPoints: item.points.total,
                    placementPoints: item.points.placementPoints,
                    achievementPoints: item.points.achievementPoints,
                    mode: .weekly
                )
                .padding(.horizontal)
                
                if index < viewModel.weeklyStandings.count - 1 {
                    Divider()
                        .padding(.leading)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var standingsSection: some View {
        BrandedSectionCard {
            HStack {
                Text("All-Time Standings")
                    .font(.system(.headline, design: .serif))
                Spacer()
                ShareLink(item: viewModel.allTimeStandingsShareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.subheadline)
                }
                .accessibilityLabel("Share all-time standings")
            }
            .padding(.horizontal)
            .padding(.top)
            
            ForEach(Array(viewModel.tournamentStandings.enumerated()), id: \.element.player.id) { index, item in
                StandingsRow(
                    rank: index + 1,
                    name: viewModel.displayName(for: item.player),
                    totalPoints: item.totalPoints,
                    placementPoints: item.player.placementPoints,
                    achievementPoints: item.player.achievementPoints,
                    wins: item.player.wins,
                    mode: .tournament
                )
                .padding(.horizontal)
                
                if index < viewModel.tournamentStandings.count - 1 {
                    Divider()
                        .padding(.leading)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var playersSection: some View {
        BrandedSectionCard {
            Text("Player Stats")
                .font(.system(.headline, design: .serif))
                .padding(.horizontal)
                .padding(.top)

            ForEach(viewModel.playersByPoints, id: \.id) { player in
                NavigationLink(value: player) {
                    PlayerRow(
                        name: viewModel.displayName(for: player),
                        mode: .display(
                            subtitle: viewModel.statsSubtitle(for: player),
                            showAvatar: true,
                            playerId: player.id,
                            rank: viewModel.rank(for: player),
                            recentPlacements: viewModel.recentPlacements(for: player),
                            sparklinePoints: viewModel.sparklinePoints(for: player)
                        )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if player.id != viewModel.playersByPoints.last?.id {
                    Divider()
                        .padding(.leading)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    @ViewBuilder
    private var chartsSectionContent: some View {
        if viewModel.hasGameResults {
            chartsSections
        } else {
            BrandedSectionCard {
                Text("No chart data yet")
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Charts (used in Charts segment)
    
    @ViewBuilder
    private var chartsSections: some View {
        BrandedSectionCard {
            BarChartView.playerPoints(
                title: "Points Comparison",
                data: viewModel.playerPointsComparison,
                height: 220
            )
        }
        
        BrandedSectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Performance Trends")
                    .font(.system(.headline, design: .serif))
                
                Group {
                    if AdaptiveLayout.usesMenuPickerStyle(
                        dynamicType: dynamicTypeSize,
                        verticalSizeClass: verticalSizeClass,
                        horizontalSizeClass: horizontalSizeClass
                    ) {
                        playerPicker
                            .pickerStyle(.menu)
                    } else {
                        playerPicker
                            .pickerStyle(.segmented)
                    }
                }
                .padding(.bottom, 4)
                
                if !viewModel.selectedPlayerPerformanceTrend.isEmpty {
                    LineChartView.performanceTrend(
                        title: "",
                        data: viewModel.selectedPlayerPerformanceTrend,
                        showArea: true,
                        height: 180
                    )
                } else {
                    noDataPlaceholder(height: 180)
                }
            }
            .padding()
        }
        
        BrandedSectionCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Placement Distribution")
                    .font(.system(.headline, design: .serif))
                
                Picker("Player", selection: Binding(
                    get: { viewModel.selectedPlayerId ?? viewModel.players.first?.id ?? "" },
                    set: { viewModel.selectedPlayerId = $0 }
                )) {
                    ForEach(viewModel.players, id: \.id) { player in
                        Text(viewModel.displayName(for: player)).tag(player.id)
                    }
                }
                .pickerStyle(.menu)
                
                let distribution = viewModel.selectedPlayerPlacementDistribution
                if distribution.contains(where: { $0.count > 0 }) {
                    PieChartView.placementDistribution(
                        title: "",
                        data: distribution,
                        style: .donut,
                        height: 160
                    )
                } else {
                    noDataPlaceholder(height: 160)
                }
            }
            .padding()
        }
        
        if !viewModel.achievementLeaderboard.isEmpty {
            BrandedSectionCard {
                BarChartView.achievementLeaderboard(
                    title: "Most Earned Achievements",
                    data: Array(viewModel.achievementLeaderboard.prefix(5)),
                    height: 200
                )
            }
        }
        
        BrandedSectionCard {
            BarChartView.winsComparison(
                title: "Wins by Player",
                data: viewModel.winsComparison,
                height: 180
            )
        }
        
        if viewModel.topAchievementEarners.contains(where: { $0.achievementPoints > 0 }) {
            BrandedSectionCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Top Achievement Earners")
                        .font(.system(.headline, design: .serif))
                    
                    let data = viewModel.topAchievementEarners
                        .filter { $0.achievementPoints > 0 }
                        .prefix(5)
                        .map { BarChartData(id: $0.id, label: $0.name, value: $0.achievementPoints) }
                    
                    Chart(data) { item in
                        BarMark(
                            x: .value("Player", item.label),
                            y: .value("Achievement Points", item.primaryValue)
                        )
                        .foregroundStyle(Color(uiColor: .systemGreen).gradient)
                        .annotation(position: .top) {
                            if item.primaryValue > 0 {
                                Text("\(item.primaryValue)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .frame(height: 180)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Top Achievement Earners")
                    .accessibilityValue(ChartAccessibility.barChartSummary(title: "Top Achievement Earners", data: Array(data)))
                }
                .padding()
            }
        }
    }

    private var playerPicker: some View {
        Picker("Player", selection: Binding(
            get: { viewModel.selectedPlayerId ?? viewModel.players.first?.id ?? "" },
            set: { viewModel.selectedPlayerId = $0 }
        )) {
            ForEach(viewModel.players, id: \.id) { player in
                Text(viewModel.displayName(for: player)).tag(player.id)
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func noDataPlaceholder(height: CGFloat) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("No data yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        StatsView(viewModel: StatsViewModel(context: PreviewContainer.shared.mainContext))
    }
}
