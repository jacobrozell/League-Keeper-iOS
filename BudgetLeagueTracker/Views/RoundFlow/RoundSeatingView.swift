import SwiftUI

/// Seating and seatings-ready phases of the round flow.
struct RoundSeatingView: View {
    @Bindable var viewModel: TournamentDetailViewModel
    var showsSeatPlayersCoachMark: Bool = false
    var onDismissSeatPlayersCoachMark: (() -> Void)? = nil
    var usesSidebarLayout: Bool
    var horizontalSizeClass: UserInterfaceSizeClass?
    var includeSidebarSections: Bool
    var onMovePlayerFeedback: (Int) -> Void

    var body: some View {
        switch viewModel.roundPhase {
        case .seating:
            seatingPhaseList
        case .seatingsReady:
            seatingsReadyList
        default:
            EmptyView()
        }
    }

    // MARK: - Seating

    @ViewBuilder
    private var seatingPhaseList: some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadSeatingEmptyContent
        } else {
            seatingPhasePhoneList
        }
    }

    @ViewBuilder
    private var seatingPhasePhoneList: some View {
        List {
            if showsSeatPlayersCoachMark {
                Section {
                    CoachMarkBanner(
                        title: "Ready to seat players",
                        message: "When everyone's here, use Seat Players below to assign tables of four for Round \(viewModel.currentRound).",
                        onDismiss: { onDismissSeatPlayersCoachMark?() }
                    )
                }
            }

            if includeSidebarSections {
                if let hint = viewModel.tableLayoutHint {
                    Section {
                        HintText(message: hint)
                    }
                }

                RoundAchievementsPreviewSection(viewModel: viewModel)
            }

            Section {
                VStack(spacing: 16) {
                    EmptyStateView(
                        message: "No tables yet",
                        hint: "Use Seat Players below to assign tables of four for Round \(viewModel.currentRound)."
                    )
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var ipadSeatingEmptyContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                if showsSeatPlayersCoachMark {
                    CoachMarkBanner(
                        title: "Ready to seat players",
                        message: "When everyone's here, use Seat Players below to assign tables of four for Round \(viewModel.currentRound).",
                        onDismiss: { onDismissSeatPlayersCoachMark?() }
                    )
                }

                EmptyStateView(
                    message: "No tables yet",
                    hint: "Use Seat Players below to assign tables of four for Round \(viewModel.currentRound)."
                )
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .padding(.top, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Seatings ready

    @ViewBuilder
    private var seatingsReadyList: some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadSeatingsReadyContent
        } else {
            seatingsReadyPhoneList
        }
    }

    @ViewBuilder
    private var seatingsReadyPhoneList: some View {
        List {
            if includeSidebarSections {
                if let hint = viewModel.tableLayoutHint {
                    Section {
                        HintText(message: hint)
                    }
                }

                RoundAchievementsPreviewSection(viewModel: viewModel)
            }

            Section {
                HintText(message: viewModel.canEditSeatings
                    ? "Review who's at each table. Use the move control to swap players between tables, then start scoring."
                    : "Review who's at each table, then start scoring.")
            }

            if viewModel.canEditSeatings {
                Section("Tables for Round \(viewModel.currentRound)") {
                    ForEach(Array(viewModel.tables.enumerated()), id: \.offset) { index, pod in
                        EditableTableSeatingCard(
                            tableNumber: index + 1,
                            players: pod,
                            displayName: viewModel.displayName(for:),
                            tableCount: viewModel.tables.count,
                            onMovePlayer: { playerId, destination in
                                viewModel.movePlayer(playerId, fromTable: index, toTable: destination)
                                onMovePlayerFeedback(destination + 1)
                            }
                        )
                    }
                }
            } else {
                Section("Tables for Round \(viewModel.currentRound)") {
                    ForEach(Array(viewModel.tables.enumerated()), id: \.offset) { index, pod in
                        TableSeatingCard(
                            tableNumber: index + 1,
                            playerNames: pod.map { viewModel.displayName(for: $0) }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var ipadSeatingsReadyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.tables.count == 1 {
                    Spacer(minLength: 32)
                }

                Text("Review who's at each table, then start scoring.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Tables for Round \(viewModel.currentRound)")
                    .font(.title3.weight(.semibold))

                LazyVGrid(
                    columns: AdaptiveLayout.tableCardGridColumns(
                        tableCount: viewModel.tables.count,
                        horizontalSizeClass: horizontalSizeClass
                    ),
                    alignment: .leading,
                    spacing: 16
                ) {
                    if viewModel.canEditSeatings {
                        ForEach(Array(viewModel.tables.enumerated()), id: \.offset) { index, pod in
                            editableTableCard(tableIndex: index, pod: pod)
                        }
                    } else {
                        ForEach(Array(viewModel.tables.enumerated()), id: \.offset) { index, pod in
                            TableSeatingCard(
                                tableNumber: index + 1,
                                playerNames: pod.map { viewModel.displayName(for: $0) },
                                style: .card
                            )
                        }
                    }
                }

                if viewModel.tables.count == 1 {
                    Spacer(minLength: 32)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: viewModel.tables.count == 1 ? 520 : nil, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func editableTableCard(tableIndex: Int, pod: [Player]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Table \(tableIndex + 1)")
                .font(.title3.weight(.semibold))

            ForEach(pod, id: \.id) { player in
                HStack {
                    Text(viewModel.displayName(for: player))
                        .font(.body)
                    Spacer()
                    Menu {
                        ForEach(viewModel.tables.indices, id: \.self) { destination in
                            if destination != tableIndex {
                                Button("Move to Table \(destination + 1)") {
                                    viewModel.movePlayer(player.id, fromTable: tableIndex, toTable: destination)
                                    onMovePlayerFeedback(destination + 1)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Move \(viewModel.displayName(for: player))")
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
