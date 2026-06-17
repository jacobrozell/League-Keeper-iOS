import SwiftUI

/// Tournament detail view - landing page for a tournament.
/// Shows different content based on tournament status (ongoing vs completed).
/// For ongoing: attendance, round flow, and standings.
/// For completed: final standings and tournament summary.
struct TournamentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Bindable var viewModel: TournamentDetailViewModel
    var showsAttendanceCoachMark: Bool = false
    var onDismissAttendanceCoachMark: (() -> Void)? = nil
    var showsGeneratePodsCoachMark: Bool = false
    var onDismissGeneratePodsCoachMark: (() -> Void)? = nil
    @State private var attendanceViewModel: AttendanceViewModel?
    @State private var showFinalStandingsSheet = false
    @State private var showNextRoundConfirmation = false
    @State private var showEditLastRoundConfirmation = false
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
                    showToast("Attendance updated")
                    viewModel.refresh()
                    viewModel.setTab(.round)
                }
            )
        }
        .onChange(of: viewModel.tournament?.status) { _, newStatus in
            if newStatus == .completed {
                AppHaptics.success()
                showFinalStandingsSheet = true
            }
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
        .alert("Edit last round?", isPresented: $showEditLastRoundConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Edit") {
                viewModel.editLastRound()
            }
        } message: {
            Text("Opens the last completed round so you can fix placements and achievements.")
        }
        .overlay(alignment: .top) {
            if let toastMessage {
                ToastBanner(message: toastMessage)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: toastMessage)
    }
    
    // MARK: - Ongoing Tournament Content
    
    @ViewBuilder
    private var ongoingContent: some View {
        VStack(spacing: 0) {
            progressHeader

            sectionTabPicker

            // Tab content
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
                .padding(.vertical, 8)
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
                .padding(.vertical, 8)
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
                    showsCoachMark: showsAttendanceCoachMark && !viewModel.hasPresentPlayers,
                    onDismissCoachMark: onDismissAttendanceCoachMark,
                onConfirm: {
                    showToast("Attendance confirmed")
                    AppAccessibility.announce("Attendance confirmed. Round section is ready for seating.")
                    onDismissAttendanceCoachMark?()
                    viewModel.refresh()
                    viewModel.setTab(.round)
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
            showsSeatPlayersCoachMark: showsGeneratePodsCoachMark && viewModel.pods.isEmpty,
            onDismissSeatPlayersCoachMark: onDismissGeneratePodsCoachMark,
            onShowToast: showToast,
            onRequestFinishRound: { showNextRoundConfirmation = true },
            onRequestEditLastRound: { showEditLastRoundConfirmation = true }
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
        AppAccessibility.announce(message)
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
