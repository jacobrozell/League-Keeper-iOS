import SwiftUI
import SwiftData

/// Tournament detail view - landing page for a tournament.
/// Shows different content based on tournament status (ongoing vs completed).
/// For ongoing: attendance, round flow, and standings.
/// For completed: final standings and tournament summary.
struct TournamentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Bindable var viewModel: TournamentDetailViewModel
    var showsAttendanceCoachMark: Bool = false
    var onDismissAttendanceCoachMark: (() -> Void)? = nil
    var showsGeneratePodsCoachMark: Bool = false
    var onDismissGeneratePodsCoachMark: (() -> Void)? = nil
    @State private var attendanceCoachMarkDismissed = false
    @State private var generatePodsCoachMarkDismissed = false
    @State private var attendanceViewModel: AttendanceViewModel?
    @State private var showFinalStandingsSheet = false
    @State private var showNextRoundConfirmation = false
    @State private var showEditLastRoundConfirmation = false
    @State private var showReopenScoringConfirmation = false
    @State private var showRulesSheet = false
    @State private var showStandingsDisplay = false
    @State private var showEditRoundPicker = false
    @State private var toastMessage: String?
    
    var body: some View {
        Group {
            if viewModel.isOngoing {
                ongoingContent
            } else {
                completedContent
            }
        }
        .navigationTitle(viewModel.tournamentName)
        .navigationBarTitleDisplayMode(
            viewModel.isOngoing && viewModel.hasPresentPlayers ? .inline : .large
        )
        .toolbar { tournamentToolbar }
        .sheet(isPresented: $showRulesSheet) {
            NavigationStack {
                TournamentRulesSummaryView(rules: viewModel.tournamentRules)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showRulesSheet = false }
                        }
                    }
            }
            .presentationDetents([.large])
        }
        .onAppear {
            viewModel.setAsActiveTournament()
            viewModel.refresh()
            attendanceViewModel = AttendanceViewModel(context: modelContext)
        }
        .sheet(isPresented: $viewModel.showEditLastRound) {
            EditLastRoundView(
                viewModel: EditLastRoundViewModel(
                    context: modelContext,
                    tournamentId: viewModel.tournamentId,
                    snapshotIndex: viewModel.editSnapshotIndex
                ),
                onSave: { editedRound in
                    viewModel.onEditLastRoundSaved()
                    AppHaptics.success()
                    showToast("Round \(editedRound) updated")
                }
            )
        }
        .sheet(isPresented: $showEditRoundPicker) {
            EditRoundPickerView(
                rounds: viewModel.editableRoundsThisWeek,
                onSelect: { index in
                    showEditRoundPicker = false
                    viewModel.editRound(snapshotIndex: index)
                },
                onCancel: { showEditRoundPicker = false }
            )
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showStandingsDisplay) {
            StandingsDisplayView(
                title: viewModel.tournamentName,
                subtitle: viewModel.standingsDisplaySubtitle,
                rows: viewModel.standingsDisplayRows,
                shareText: viewModel.standingsDisplayShareText,
                onRefresh: { viewModel.refresh() },
                onDismiss: { showStandingsDisplay = false }
            )
        }
        .onChange(of: viewModel.tournament?.status) { _, newStatus in
            handleTournamentStatusChange(newStatus)
        }
        .sheet(isPresented: $showFinalStandingsSheet, onDismiss: {}) {
            TournamentStandingsView(viewModel: TournamentStandingsViewModel(context: modelContext))
        }
        .alert(
            viewModel.nextRoundConfirmationTitle,
            isPresented: $showNextRoundConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button(viewModel.nextRoundConfirmActionTitle) {
                confirmNextRound()
            }
        } message: {
            Text(viewModel.nextRoundConfirmationMessage)
        }
        .fullScreenCover(isPresented: $viewModel.showWeekCompleteSheet) {
            WeekCompleteSheetView(
                tournamentName: viewModel.tournamentName,
                week: viewModel.completedWeekNumber ?? max(viewModel.currentWeek - 1, 1),
                standings: viewModel.completedWeekStandings,
                nextWeek: viewModel.currentWeek,
                displayName: viewModel.displayName(for:),
                onContinue: { viewModel.dismissWeekCompleteSheet() }
            )
        }
        .alert("Edit scored round?", isPresented: $showEditLastRoundConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button(viewModel.editRoundConfirmationButtonTitle) {
                let rounds = viewModel.editableRoundsThisWeek
                if rounds.count == 1, let only = rounds.first {
                    viewModel.editRound(snapshotIndex: only.snapshotIndex)
                } else {
                    showEditRoundPicker = true
                }
            }
        } message: {
            Text(viewModel.editRoundConfirmationMessage)
        }
        .alert("Back to scoring?", isPresented: $showReopenScoringConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear Scores", role: .destructive) {
                viewModel.reopenScoring()
                showToast("Update table results, then review again")
            }
        } message: {
            Text("Clears saved placements and bonuses for every table this round so you can score again.")
        }
        .overlay(alignment: .top) {
            if let toastMessage {
                ToastBanner(message: toastMessage)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: toastMessage)
        .onChange(of: viewModel.persistenceErrorMessage) { _, message in
            if let message {
                showToast(message)
                viewModel.clearPersistenceError()
            }
        }
    }

    private var showsAttendanceCoachMarkBanner: Bool {
        showsAttendanceCoachMark && !attendanceCoachMarkDismissed
    }

    private var showsGeneratePodsCoachMarkBanner: Bool {
        showsGeneratePodsCoachMark && !generatePodsCoachMarkDismissed
    }

    @ToolbarContentBuilder
    private var tournamentToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 16) {
                if !viewModel.standingsDisplayRows.isEmpty {
                    Button {
                        showStandingsDisplay = true
                    } label: {
                        Label("Table Display", systemImage: "display")
                    }
                    .adaptiveToolbarLabelStyle(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize)
                    .accessibilityLabel("Table display mode")
                    .accessibilityIdentifier("Standings Display")
                }

                Button {
                    showRulesSheet = true
                } label: {
                    Label("House Rules", systemImage: "book.closed")
                }
                .adaptiveToolbarLabelStyle(isAccessibilitySize: dynamicTypeSize.isAccessibilitySize)
                .accessibilityLabel("House Rules")
                .accessibilityIdentifier("Tournament Rules")
            }
        }
    }

    private func handleTournamentStatusChange(_ newStatus: TournamentStatus?) {
        if newStatus == .completed {
            AppHaptics.success()
            showFinalStandingsSheet = true
        }
    }

    private func dismissAttendanceCoachMark() {
        attendanceCoachMarkDismissed = true
        onDismissAttendanceCoachMark?()
    }

    private func dismissGeneratePodsCoachMark() {
        generatePodsCoachMarkDismissed = true
        onDismissGeneratePodsCoachMark?()
    }
    
    // MARK: - Ongoing Tournament Content
    
    @ViewBuilder
    private var ongoingContent: some View {
        VStack(spacing: 0) {
            progressHeader
                .frame(maxWidth: .infinity, alignment: .leading)

            sectionTabPicker
                .frame(maxWidth: .infinity)

            Group {
                switch viewModel.activeTab {
                case .attendance:
                    attendanceTabContent
                case .round:
                    roundTabContent
                case .standings:
                    standingsTabContent
                }
            }
            .id(viewModel.activeTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .adaptiveContentWidth()
    }

    @ViewBuilder
    private var sectionTabPicker: some View {
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
                    Picker("Section", selection: sectionTabSelection) {
                        ForEach(TournamentDetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("tournamentDetailSectionPicker")
                    .accessibilitySelectedSection("Section", value: viewModel.activeTab.rawValue)
                }
                .padding(.horizontal)
                .padding(.vertical, chromePadding)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                Picker("Section", selection: sectionTabSelection) {
                    ForEach(TournamentDetailTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("tournamentDetailSectionPicker")
                .accessibilitySelectedSection("Section", value: viewModel.activeTab.rawValue)
                .padding(.horizontal)
                .padding(.vertical, chromePadding)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
            }
        }
    }

    private var sectionTabSelection: Binding<TournamentDetailTab> {
        Binding(
            get: { viewModel.activeTab },
            set: { viewModel.setTab($0, userInitiated: true) }
        )
    }
    
    @ViewBuilder
    private var progressHeader: some View {
        TournamentProgressHeader(
            weekLabel: viewModel.weekProgressString,
            roundLabel: viewModel.roundString,
            steps: viewModel.progressSteps,
            currentRound: viewModel.currentRound,
            roundsPerWeek: AppConstants.League.roundsPerWeek,
            nextStepHint: viewModel.nextStepHint
        )
    }

    @ViewBuilder
    private var attendanceTabContent: some View {
        Group {
            if let vm = attendanceViewModel {
                AttendanceView(
                    viewModel: vm,
                    showsConfirmedBanner: viewModel.hasPresentPlayers,
                    showsCoachMark: showsAttendanceCoachMarkBanner && !viewModel.hasPresentPlayers,
                    onDismissCoachMark: dismissAttendanceCoachMark,
                onConfirm: { wasUpdate, clearedTables in
                    if clearedTables {
                        showToast("Attendance updated — seat players again for this round")
                    } else {
                        showToast(wasUpdate ? "Attendance updated" : "Attendance confirmed")
                    }
                    if !wasUpdate {
                        AppAccessibility.announce("Attendance confirmed. Round section is ready for seating.")
                    }
                    dismissAttendanceCoachMark()
                    viewModel.refresh()
                    attendanceViewModel?.refresh()
                    viewModel.setTab(.round)
                },
                onSaveFailed: {
                    showToast(PersistenceError.saveFailed.toastMessage)
                }
                )
            } else {
                ProgressView()
            }
        }
    }
    
    @ViewBuilder
    private var roundTabContent: some View {
        RoundFlowView(
            viewModel: viewModel,
            showsSeatPlayersCoachMark: showsGeneratePodsCoachMarkBanner && viewModel.pods.isEmpty,
            onDismissSeatPlayersCoachMark: dismissGeneratePodsCoachMark,
            onShowToast: showToast,
            onRequestFinishRound: { showNextRoundConfirmation = true },
            onRequestEditLastRound: { showEditLastRoundConfirmation = true },
            onRequestReopenScoring: { showReopenScoringConfirmation = true }
        )
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
                .accessibilityLabel("Standings week")
                .accessibilityValue(viewModel.standingsWeekPickerLabel)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            if viewModel.standingsForDisplay.isEmpty {
                Spacer()
                EmptyStateView(
                    message: "No standings yet",
                    hint: "Score a round to see weekly and tournament standings here.",
                    systemImage: "list.number"
                )
                Spacer()
            } else {
                VStack(spacing: 0) {
                    Button {
                        showStandingsDisplay = true
                    } label: {
                        Label("Show on Table", systemImage: "display")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .accessibilityIdentifier("showStandingsDisplay")

                    List {
                        ForEach(Array(viewModel.standingsForDisplay.enumerated()), id: \.element.player.id) { index, standing in
                            StandingsRow(
                                rank: index + 1,
                                name: viewModel.displayName(for: standing.player),
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
    
    // MARK: - Actions

    private func confirmNextRound() {
        let finishedRound = viewModel.currentRound
        let wasEndOfWeek = finishedRound >= AppConstants.League.roundsPerWeek
        let completedWeek = viewModel.currentWeek

        viewModel.nextRound()
        AppHaptics.success()

        if viewModel.showWeekCompleteSheet {
            showToast("Week \(completedWeek) complete")
        } else if wasEndOfWeek {
            showToast("Week \(viewModel.currentWeek) started")
        } else {
            showToast("Round \(finishedRound) saved")
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
    
    // MARK: - Completed Tournament Content
    
    @ViewBuilder
    private var completedContent: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                StatusChip(
                    label: "Tournament complete",
                    colorHex: "#FF9500",
                    accessibilityPrefix: "Status"
                )

                if let winner = viewModel.winnerName {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.title2)
                            .foregroundStyle(AppConstants.AccessibleColors.winnerAccent)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Champion")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(winner)
                                .font(.system(.title2, design: .serif).weight(.semibold))
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Champion, \(winner)")
                }

                Text(viewModel.dateRangeString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(viewModel.totalWeeks) weeks · \(viewModel.finalStandings.count) players")
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
                            name: viewModel.displayName(for: standing.player),
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
        .adaptiveContentWidth()
    }
}

/// Keeps a stable `TournamentDetailViewModel` across parent re-renders so tab selection isn't reset.
struct TournamentDetailRoute: View {
    @Environment(\.modelContext) private var modelContext

    let tournamentId: String
    let showsAttendanceCoachMark: Bool
    let onDismissAttendanceCoachMark: () -> Void
    let showsGeneratePodsCoachMark: Bool
    let onDismissGeneratePodsCoachMark: () -> Void

    @State private var viewModel: TournamentDetailViewModel

    init(
        context: ModelContext,
        tournamentId: String,
        showsAttendanceCoachMark: Bool,
        onDismissAttendanceCoachMark: @escaping () -> Void,
        showsGeneratePodsCoachMark: Bool,
        onDismissGeneratePodsCoachMark: @escaping () -> Void
    ) {
        self.tournamentId = tournamentId
        self.showsAttendanceCoachMark = showsAttendanceCoachMark
        self.onDismissAttendanceCoachMark = onDismissAttendanceCoachMark
        self.showsGeneratePodsCoachMark = showsGeneratePodsCoachMark
        self.onDismissGeneratePodsCoachMark = onDismissGeneratePodsCoachMark
        _viewModel = State(
            initialValue: TournamentDetailViewModel(context: context, tournamentId: tournamentId)
        )
    }

    var body: some View {
        TournamentDetailView(
            viewModel: viewModel,
            showsAttendanceCoachMark: showsAttendanceCoachMark,
            onDismissAttendanceCoachMark: onDismissAttendanceCoachMark,
            showsGeneratePodsCoachMark: showsGeneratePodsCoachMark,
            onDismissGeneratePodsCoachMark: onDismissGeneratePodsCoachMark
        )
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
