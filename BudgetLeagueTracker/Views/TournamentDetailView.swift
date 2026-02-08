import SwiftUI

/// Tournament detail view - landing page for a tournament.
/// Shows different content based on tournament status (ongoing vs completed).
/// For ongoing: attendance, pods, weekly standings with full pod management.
/// For completed: final standings and tournament summary.
struct TournamentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: TournamentDetailViewModel
    @State private var attendanceViewModel: AttendanceViewModel?
    @State private var showFinalStandingsSheet = false
    
    var body: some View {
        Group {
            if viewModel.isOngoing {
                ongoingContent
            } else {
                completedContent
            }
        }
        .navigationTitle(viewModel.tournamentName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.setAsActiveTournament()
            viewModel.refresh()
            attendanceViewModel = AttendanceViewModel(context: modelContext)
        }
        .sheet(isPresented: $viewModel.showEditLastRound) {
            EditLastRoundView(
                viewModel: EditLastRoundViewModel(
                    context: modelContext,
                    tournamentId: viewModel.tournamentId
                ),
                onSave: { viewModel.onEditLastRoundSaved() }
            )
        }
        .sheet(isPresented: $viewModel.showAttendance) {
            AttendanceView(
                viewModel: AttendanceViewModel(context: modelContext),
                onConfirm: {
                    viewModel.showAttendance = false
                    viewModel.refresh()
                    viewModel.activeTab = .pods
                }
            )
        }
        .onChange(of: viewModel.tournament?.status) { _, newStatus in
            if newStatus == .completed {
                showFinalStandingsSheet = true
            }
        }
        .sheet(isPresented: $showFinalStandingsSheet, onDismiss: {}) {
            TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: modelContext))
        }
    }
    
    // MARK: - Ongoing Tournament Content
    
    @ViewBuilder
    private var ongoingContent: some View {
        VStack(spacing: 0) {
            // Info bar
            infoBar
            
            // Segmented control: Attendance | Pods | Standings
            Picker("Section", selection: $viewModel.activeTab) {
                ForEach(TournamentDetailTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Tab content
            Group {
                switch viewModel.activeTab {
                case .attendance:
                    attendanceTabContent
                case .pods:
                    podsTabContent
                case .standings:
                    standingsTabContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var infoBar: some View {
        HStack {
            Text(viewModel.weekProgressString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(viewModel.roundString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
    
    @ViewBuilder
    private var attendanceTabContent: some View {
        Group {
            if let vm = attendanceViewModel {
                AttendanceView(
                    viewModel: vm,
                    onConfirm: {
                        viewModel.refresh()
                        viewModel.activeTab = .pods
                    }
                )
            } else {
                ProgressView()
            }
        }
    }
    
    @ViewBuilder
    private var podsTabContent: some View {
        Group {
            if !viewModel.hasPresentPlayers {
                VStack(spacing: 16) {
                    Spacer()
                    HintText(message: "Mark attendance before generating pods.")
                    Button {
                        viewModel.goToAttendance()
                    } label: {
                        Text("Mark Attendance")
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            } else {
                List {
                    actionsSection
                    if !viewModel.pods.isEmpty {
                        ForEach(Array(viewModel.pods.enumerated()), id: \.offset) { index, pod in
                            Section("Pod \(index + 1)") {
                                podContent(pod: pod)
                            }
                        }
                    } else {
                        Section {
                            EmptyStateView(
                                message: "No pods generated",
                                hint: "Tap Generate to create pods for this round."
                            )
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    @ViewBuilder
    private var standingsTabContent: some View {
        VStack(spacing: 0) {
            // Week selector
            HStack {
                Text("View by week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Week", selection: $viewModel.selectedStandingsWeek) {
                    ForEach(Array(viewModel.standingsWeekOptions.enumerated()), id: \.offset) { _, option in
                        Text(option.label).tag(option.week as Int?)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            if viewModel.standingsForDisplay.isEmpty {
                Spacer()
                Text("No standings yet")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.standingsForDisplay.enumerated()), id: \.element.player.id) { index, standing in
                        StandingsRow(
                            rank: index + 1,
                            name: standing.player.name,
                            totalPoints: standing.totalPoints,
                            placementPoints: standing.placementPoints,
                            achievementPoints: standing.achievementPoints,
                            wins: standing.wins ?? 0,
                            mode: standing.wins != nil ? .tournament : .weekly
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    // MARK: - Actions Section
    
    @ViewBuilder
    private var actionsSection: some View {
        Section("Actions") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    PrimaryActionButton(
                        title: "Generate",
                        action: { viewModel.generatePods() },
                        isDisabled: !viewModel.canGeneratePods
                    )
                    
                    SecondaryButton(
                        title: "Next Round",
                        action: { viewModel.nextRound() }
                    )
                }
                
                SecondaryButton(
                    title: "Edit Last Round",
                    action: { viewModel.editLastRound() },
                    isDisabled: !viewModel.canEdit
                )
                
                // Option to change attendance
                Button {
                    viewModel.goToAttendance()
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Edit Attendance")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Pod Content
    
    @ViewBuilder
    private func podContent(pod: [Player]) -> some View {
        ForEach(pod, id: \.id) { player in
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.headline)
                
                PlacementPicker(
                    playerName: player.name,
                    selection: Binding(
                        get: { viewModel.placement(for: player.id) },
                        set: { viewModel.setPlacement(for: player.id, place: $0) }
                    ),
                    isDisabled: false
                )
                
                if viewModel.achievementsOnThisWeek && !viewModel.activeAchievements.isEmpty {
                    ForEach(viewModel.activeAchievements, id: \.id) { achievement in
                        AchievementCheckItem(
                            name: achievement.name,
                            points: achievement.points,
                            isChecked: Binding(
                                get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                                set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                            ),
                            isDisabled: false
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Completed Tournament Content
    
    @ViewBuilder
    private var completedContent: some View {
        VStack(spacing: 0) {
            // Summary header
            VStack(alignment: .leading, spacing: 8) {
                if let winner = viewModel.winnerName {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(AppConstants.AccessibleColors.winnerAccent)
                        Text("Winner: \(winner)")
                            .font(.headline)
                    }
                }
                Text(viewModel.dateRangeString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.totalWeeks) weeks • \(viewModel.finalStandings.count) players")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Week selector (same as ongoing standings)
            HStack {
                Text("View by week")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Week", selection: $viewModel.selectedStandingsWeek) {
                    ForEach(Array(viewModel.standingsWeekOptions.enumerated()), id: \.offset) { _, option in
                        Text(option.label).tag(option.week as Int?)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            if viewModel.standingsForDisplay.isEmpty {
                Spacer()
                Text("No standings available")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.standingsForDisplay.enumerated()), id: \.element.player.id) { index, standing in
                        StandingsRow(
                            rank: index + 1,
                            name: standing.player.name,
                            totalPoints: standing.totalPoints,
                            placementPoints: standing.placementPoints,
                            achievementPoints: standing.achievementPoints,
                            wins: standing.wins ?? 0,
                            mode: standing.wins != nil ? .tournament : .weekly
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

#Preview("Ongoing") {
    NavigationStack {
        TournamentDetailView(
            viewModel: TournamentDetailViewModel(
                context: PreviewContainer.shared.mainContext,
                tournamentId: "preview"
            )
        )
    }
}

#Preview("Completed") {
    NavigationStack {
        TournamentDetailView(
            viewModel: TournamentDetailViewModel(
                context: PreviewContainer.shared.mainContext,
                tournamentId: "completed-preview"
            )
        )
    }
}
