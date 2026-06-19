import SwiftUI

/// Guided round flow: seat tables, score one at a time, review, then finish the round.
struct RoundFlowView: View {
    @Bindable var viewModel: TournamentDetailViewModel
    var showsSeatPlayersCoachMark: Bool = false
    var onDismissSeatPlayersCoachMark: (() -> Void)? = nil
    var onShowToast: (String) -> Void
    var onRequestFinishRound: () -> Void
    var onRequestEditLastRound: () -> Void
    var onRequestReopenScoring: () -> Void
    var onRequestUndoLastTable: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var usesSidebarLayout: Bool {
        AdaptiveLayout.usesTwoColumnLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    var body: some View {
        Group {
            if !viewModel.hasPresentPlayers {
                attendanceRequiredState
            } else {
                roundContent
            }
        }
    }

    // MARK: - States

    @ViewBuilder
    private var attendanceRequiredState: some View {
        VStack(spacing: 16) {
            Spacer()
            HintText(message: "Mark attendance before seating players.")
            Button {
                viewModel.goToAttendance()
            } label: {
                Text("Mark Attendance")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Mark attendance")
            Spacer()
        }
    }

    @ViewBuilder
    private var roundContent: some View {
        Group {
            if usesSidebarLayout {
                AdaptiveSidebarLayout {
                    ScrollView {
                        roundSidebarPanels
                    }
                    .scrollBounceBehavior(.basedOnSize)
                } main: {
                    roundPhaseMainContent
                }
                .padding(.horizontal, 16)
            } else {
                roundPhaseMainContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            roundStickyActionsBar
        }
    }

    @ViewBuilder
    private var roundPhaseMainContent: some View {
        VStack(spacing: 0) {
            if let issue = viewModel.tableLoadIssueMessage {
                HintText(message: issue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }

            switch viewModel.roundPhase {
            case .seating, .seatingsReady:
                RoundSeatingView(
                    viewModel: viewModel,
                    showsSeatPlayersCoachMark: showsSeatPlayersCoachMark,
                    onDismissSeatPlayersCoachMark: onDismissSeatPlayersCoachMark,
                    usesSidebarLayout: usesSidebarLayout,
                    horizontalSizeClass: horizontalSizeClass,
                    includeSidebarSections: !usesSidebarLayout,
                    onMovePlayerFeedback: movePlayerWithFeedback
                )
            case .scoring:
                RoundScoringView(
                    viewModel: viewModel,
                    usesSidebarLayout: usesSidebarLayout,
                    includeBonusesInList: !usesSidebarLayout
                )
            case .review:
                RoundReviewView(
                    viewModel: viewModel,
                    usesSidebarLayout: usesSidebarLayout,
                    horizontalSizeClass: horizontalSizeClass,
                    includeSidebarSections: !usesSidebarLayout
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var roundSidebarPanels: some View {
        VStack(alignment: .leading, spacing: 16) {
            RoundAchievementsPreviewPanel(viewModel: viewModel)

            if viewModel.roundPhase == .review, viewModel.hasWeeklyStandingsToShow {
                RoundWeeklyStandingsPreviewPanel(viewModel: viewModel)
            }

            if let hint = viewModel.tableLayoutHint {
                HintText(message: hint)
            }

            if viewModel.roundPhase == .scoring,
               viewModel.achievementsOnThisWeek,
               !viewModel.activeAchievements.isEmpty {
                RoundScoringBonusesPanel(viewModel: viewModel)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Sticky actions

    @ViewBuilder
    private var roundStickyActionsBar: some View {
        let stacked = AdaptiveLayout.usesStackedPodsActionBar(
            dynamicType: dynamicTypeSize,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        )

        StickyBottomActionBar {
            if stacked {
                VStack(spacing: 12) {
                    secondaryRoundActions(stacked: true)
                    primaryRoundActions(stacked: true)
                }
            } else {
                VStack(spacing: 12) {
                    secondaryRoundActions(stacked: false)
                    HStack(spacing: 12) {
                        primaryRoundActions(stacked: false)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private func secondaryRoundActions(stacked: Bool) -> some View {
        switch viewModel.roundPhase {
        case .seatingsReady where viewModel.canUndoLastTable && !viewModel.pods.isEmpty:
            SecondaryButton(
                title: "Undo Last Table",
                action: onRequestUndoLastTable,
                accessibilityLabel: "Undo last table",
                accessibilityIdentifier: "Undo Last Table"
            )
            .frame(maxWidth: stacked ? .infinity : nil)

        case .review where viewModel.canEdit:
            SecondaryButton(
                title: "Edit Scored Round",
                action: onRequestEditLastRound,
                accessibilityLabel: "Edit scored round",
                accessibilityIdentifier: "Edit Last Round"
            )
            .frame(maxWidth: stacked ? .infinity : nil)

        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func primaryRoundActions(stacked: Bool) -> some View {
        if stacked {
            VStack(spacing: 12) {
                primaryActionContent
            }
        } else {
            HStack(spacing: 12) {
                primaryActionContent
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var primaryActionContent: some View {
        switch viewModel.roundPhase {
        case .seating:
            PrimaryActionButton(
                title: viewModel.seatPlayersButtonTitle,
                action: seatPlayersWithFeedback,
                isDisabled: !viewModel.canSeatPlayers,
                accessibilityLabel: viewModel.seatPlayersButtonTitle,
                accessibilityIdentifier: "Seat Players"
            )

        case .seatingsReady:
            SecondaryButton(
                title: "Reshuffle Tables",
                action: reshuffleWithFeedback,
                accessibilityLabel: "Reshuffle tables",
                accessibilityIdentifier: "Reshuffle Tables"
            )
            PrimaryActionButton(
                title: "Start Scoring",
                action: startScoringWithFeedback,
                accessibilityLabel: "Start scoring tables",
                accessibilityIdentifier: "Start Scoring"
            )

        case .scoring:
            if viewModel.pods.count > 1, viewModel.currentScoringTableIndex > 0 {
                SecondaryButton(
                    title: "Previous Table",
                    action: { viewModel.selectScoringTable(viewModel.currentScoringTableIndex - 1) },
                    accessibilityLabel: "Previous table"
                )
            }

            if !viewModel.isTableConfirmed(viewModel.currentScoringTableIndex) {
                PrimaryActionButton(
                    title: "Done with This Table",
                    action: confirmCurrentTableWithFeedback,
                    accessibilityLabel: "Done with this table",
                    accessibilityIdentifier: "Done with Table"
                )
            } else if let next = viewModel.pods.indices.first(where: { !viewModel.isTableConfirmed($0) }) {
                PrimaryActionButton(
                    title: "Next Table",
                    action: { viewModel.selectScoringTable(next) },
                    accessibilityLabel: "Next table",
                    accessibilityIdentifier: "Next Table"
                )
            }

        case .review:
            SecondaryButton(
                title: "Back to Scoring",
                action: onRequestReopenScoring,
                accessibilityLabel: "Back to scoring"
            )
            PrimaryActionButton(
                title: viewModel.nextRoundButtonTitle,
                action: onRequestFinishRound,
                isDisabled: !viewModel.canNextRound,
                accessibilityLabel: viewModel.nextRoundButtonTitle,
                accessibilityIdentifier: "Next Round"
            )
            .accessibilityHintIf(
                viewModel.canNextRound ? nil : "Score every table before finishing the round."
            )
        }
    }

    // MARK: - Actions

    private func seatPlayersWithFeedback() {
        viewModel.seatPlayers()
        onDismissSeatPlayersCoachMark?()
        AppHaptics.lightImpact()
        onShowToast("Tables ready for Round \(viewModel.currentRound) — review seatings, then start scoring")
    }

    private func reshuffleWithFeedback() {
        viewModel.reshuffleTables()
        AppHaptics.lightImpact()
        onShowToast("Tables reshuffled for Round \(viewModel.currentRound)")
    }

    private func startScoringWithFeedback() {
        viewModel.startScoring()
        AppHaptics.lightImpact()
        onShowToast("Score Table 1 — set finish order, then tap Done with This Table")
    }

    private func confirmCurrentTableWithFeedback() {
        let tableNumber = viewModel.currentScoringTableIndex + 1
        viewModel.confirmTable(at: viewModel.currentScoringTableIndex)
        AppHaptics.success()
        if viewModel.allTablesConfirmed {
            onShowToast("All tables scored — review, then \(viewModel.nextRoundButtonTitle)")
        } else {
            onShowToast("Table \(tableNumber) saved")
        }
    }

    private func movePlayerWithFeedback(toTable tableNumber: Int) {
        AppHaptics.lightImpact()
        onShowToast("Player moved to Table \(tableNumber)")
    }
}
