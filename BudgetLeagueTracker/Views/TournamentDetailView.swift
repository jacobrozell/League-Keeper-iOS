import SwiftUI

/// Tournament detail view - landing page for a tournament.
/// Shows different content based on tournament status (ongoing vs completed).
/// For ongoing: attendance, pods, weekly standings with full pod management.
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
                    showToast("Attendance updated")
                    viewModel.refresh()
                    viewModel.activeTab = .pods
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
                case .pods:
                    podsTabContent
                case .standings:
                    standingsTabContent
                }
            }
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
                    Picker("Section", selection: $viewModel.activeTab) {
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
                Picker("Section", selection: $viewModel.activeTab) {
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
                    AppAccessibility.announce("Attendance confirmed. Pods section is ready for matchups.")
                    onDismissAttendanceCoachMark?()
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
                    .accessibilityLabel("Mark attendance")
                    Spacer()
                }
            } else {
                List {
                    if showsGeneratePodsCoachMark, viewModel.pods.isEmpty {
                        Section {
                            CoachMarkBanner(
                                title: "Ready to seat players",
                                message: "When everyone is at the table, tap Generate Round Pods to create matchups for this round.",
                                onDismiss: { onDismissGeneratePodsCoachMark?() }
                            )
                        }
                    }

                    if let hint = viewModel.podLayoutHint {
                        Section {
                            HintText(message: hint)
                        }
                    }

                    achievementsPreviewSection

                    if viewModel.hasWeeklyStandingsToShow {
                        weeklyStandingsPreviewSection
                    }

                    if !viewModel.pods.isEmpty {
                        ForEach(Array(viewModel.pods.enumerated()), id: \.offset) { index, pod in
                            Section {
                                DisclosureGroup(
                                    isExpanded: Binding(
                                        get: { viewModel.isPodExpanded(index) },
                                        set: { viewModel.setPodExpanded(index, expanded: $0) }
                                    )
                                ) {
                                    podContent(pod: pod)
                                } label: {
                                    HStack {
                                        Text("Pod \(index + 1)")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(pod.count) players")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .accessibilityLabel("Pod \(index + 1), \(pod.count) players")
                                .accessibilityValue(viewModel.isPodExpanded(index) ? "Expanded" : "Collapsed")
                                .accessibilityHint("Double tap to \(viewModel.isPodExpanded(index) ? "collapse" : "expand") scoring controls")
                            }
                        }
                    } else {
                        Section {
                            VStack(spacing: 16) {
                                EmptyStateView(
                                    message: "No pods generated",
                                    hint: "Generate pods for the current round."
                                )
                                PrimaryActionButton(
                                    title: viewModel.generatePodsButtonTitle,
                                    action: generatePodsWithFeedback,
                                    isDisabled: !viewModel.canGeneratePods,
                                    accessibilityLabel: viewModel.generatePodsButtonTitle,
                                    accessibilityIdentifier: "Generate"
                                )
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    podsStickyActionsBar
                }
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
                .accessibilityLabel("Standings week")
                .accessibilityValue(viewModel.standingsWeekPickerLabel)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            if viewModel.standingsForDisplay.isEmpty {
                Spacer()
                Text("No standings yet")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("No standings yet")
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
    
    // MARK: - Pods Support Sections

    @ViewBuilder
    private var achievementsPreviewSection: some View {
        Section("This week's achievements") {
            if !viewModel.achievementsOnThisWeek {
                Text("Achievements are not counted this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if viewModel.activeAchievements.isEmpty {
                Text("No achievements active this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.activeAchievements, id: \.id) { achievement in
                    HStack(spacing: 12) {
                        Image(systemName: achievement.iconName)
                            .foregroundStyle(Color("BrandGold"))
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(achievement.name)
                                Spacer()
                                Text("+\(achievement.points)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            if let description = achievement.achievementDescription, !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(achievement.name), \(achievement.points) points")
                }
            }
        }
    }

    @ViewBuilder
    private var weeklyStandingsPreviewSection: some View {
        Section {
            ForEach(Array(viewModel.inlineWeeklyStandings.enumerated()), id: \.element.player.id) { index, item in
                HStack {
                    Text("\(index + 1).")
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .leading)
                    Text(item.player.name)
                    Spacer()
                    Text("\(item.points.total) pts")
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rank \(index + 1), \(item.player.name), \(item.points.total) points")
            }

            if viewModel.weeklyStandings.filter({ $0.points.total > 0 }).count > viewModel.inlineWeeklyStandings.count {
                Button("See full standings") {
                    viewModel.selectedStandingsWeek = viewModel.currentWeek
                    viewModel.activeTab = .standings
                }
                .font(.subheadline)
                .accessibilityLabel("See full standings for week \(viewModel.currentWeek)")
            }
        } header: {
            Text("Week \(viewModel.currentWeek) leaderboard")
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var podsStickyActionsBar: some View {
        let stacked = AdaptiveLayout.usesStackedRowLayout(
            dynamicType: dynamicTypeSize,
            verticalSizeClass: verticalSizeClass
        )

        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 12) {
                if stacked {
                    PrimaryActionButton(
                        title: viewModel.generatePodsButtonTitle,
                        action: generatePodsWithFeedback,
                        isDisabled: !viewModel.canGeneratePods,
                        accessibilityLabel: viewModel.generatePodsButtonTitle,
                        accessibilityIdentifier: "Generate"
                    )
                    .accessibilityHintIf(
                        viewModel.canGeneratePods ? nil : "Confirm attendance before generating pods."
                    )

                    SecondaryButton(
                        title: viewModel.nextRoundButtonTitle,
                        action: { showNextRoundConfirmation = true },
                        isDisabled: !viewModel.canNextRound,
                        accessibilityLabel: viewModel.nextRoundButtonTitle,
                        accessibilityIdentifier: "Next Round"
                    )
                    .accessibilityHintIf(
                        viewModel.canNextRound ? nil : "Generate pods and score every present player before advancing."
                    )

                    SecondaryButton(
                        title: "Edit Last Round",
                        action: { showEditLastRoundConfirmation = true },
                        isDisabled: !viewModel.canEdit,
                        accessibilityLabel: "Edit last round",
                        accessibilityIdentifier: "Edit Last Round"
                    )
                    .accessibilityHintIf(
                        viewModel.canEdit ? "Opens the last completed round for corrections." : "Complete a round before editing."
                    )

                    Button {
                        viewModel.goToAttendance()
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Edit Attendance")
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, minHeight: AppConstants.UI.minTouchTargetHeight)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Edit attendance")
                } else {
                    HStack(spacing: 12) {
                        PrimaryActionButton(
                            title: viewModel.generatePodsButtonTitle,
                            action: generatePodsWithFeedback,
                            isDisabled: !viewModel.canGeneratePods,
                            accessibilityLabel: viewModel.generatePodsButtonTitle,
                            accessibilityIdentifier: "Generate"
                        )
                        .accessibilityHintIf(
                            viewModel.canGeneratePods ? nil : "Confirm attendance before generating pods."
                        )

                        SecondaryButton(
                            title: viewModel.nextRoundButtonTitle,
                            action: { showNextRoundConfirmation = true },
                            isDisabled: !viewModel.canNextRound,
                            accessibilityLabel: viewModel.nextRoundButtonTitle,
                            accessibilityIdentifier: "Next Round"
                        )
                        .accessibilityHintIf(
                            viewModel.canNextRound ? nil : "Generate pods and score every present player before advancing."
                        )
                    }

                    HStack(spacing: 12) {
                        SecondaryButton(
                            title: "Edit Last Round",
                            action: { showEditLastRoundConfirmation = true },
                            isDisabled: !viewModel.canEdit,
                            accessibilityLabel: "Edit last round",
                            accessibilityIdentifier: "Edit Last Round"
                        )
                        .accessibilityHintIf(
                            viewModel.canEdit ? "Opens the last completed round for corrections." : "Complete a round before editing."
                        )

                        Button {
                            viewModel.goToAttendance()
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Edit Attendance")
                            }
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, minHeight: AppConstants.UI.minTouchTargetHeight)
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Edit attendance")
                    }
                }
            }
            .padding()
        }
        .background(.bar)
    }

    private func generatePodsWithFeedback() {
        viewModel.generatePods()
        onDismissGeneratePodsCoachMark?()
        AppHaptics.lightImpact()
        showToast("Round \(viewModel.currentRound) pods ready")
    }

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

    // MARK: - Pod Content
    
    @ViewBuilder
    private func podContent(pod: [Player]) -> some View {
        ForEach(pod, id: \.id) { player in
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.headline)
                    .accessibilityHidden(true)
                
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
                            iconName: achievement.iconName,
                            achievementDescription: achievement.achievementDescription,
                            exclusivity: achievement.exclusivity,
                            isChecked: Binding(
                                get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                                set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                            ),
                            isDisabled: viewModel.isAchievementCheckDisabled(playerId: player.id, achievementId: achievement.id),
                            disabledReason: "Already earned this week"
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
