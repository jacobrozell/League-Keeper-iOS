import SwiftUI

/// Guided round flow: seat tables, score one at a time, review, then finish the round.
struct RoundFlowView: View {
    @Bindable var viewModel: TournamentDetailViewModel
    var showsSeatPlayersCoachMark: Bool = false
    var onDismissSeatPlayersCoachMark: (() -> Void)? = nil
    var onShowToast: (String) -> Void
    var onRequestFinishRound: () -> Void
    var onRequestEditLastRound: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var usesSidebarLayout: Bool {
        AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: horizontalSizeClass)
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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            roundStickyActionsBar
        }
    }

    @ViewBuilder
    private var roundPhaseMainContent: some View {
        VStack(spacing: 0) {
            switch viewModel.roundPhase {
            case .seating:
                seatingPhaseList(includeSidebarSections: !usesSidebarLayout)
            case .seatingsReady:
                seatingsReadyList(includeSidebarSections: !usesSidebarLayout)
            case .scoring:
                scoringPhase(includeBonusesInList: !usesSidebarLayout)
            case .review:
                reviewPhaseList(includeSidebarSections: !usesSidebarLayout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var roundSidebarPanels: some View {
        VStack(alignment: .leading, spacing: 16) {
            achievementsPreviewPanel

            if viewModel.roundPhase == .review, viewModel.hasWeeklyStandingsToShow {
                weeklyStandingsPreviewPanel
            }

            if let hint = viewModel.tableLayoutHint {
                HintText(message: hint)
            }

            if viewModel.roundPhase == .scoring,
               viewModel.achievementsOnThisWeek,
               !viewModel.activeAchievements.isEmpty {
                scoringBonusesPanel
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Seating

    @ViewBuilder
    private func seatingPhaseList(includeSidebarSections: Bool) -> some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadSeatingEmptyContent
        } else {
            seatingPhasePhoneList(includeSidebarSections: includeSidebarSections)
        }
    }

    @ViewBuilder
    private func seatingPhasePhoneList(includeSidebarSections: Bool) -> some View {
        List {
            if showsSeatPlayersCoachMark {
                Section {
                    CoachMarkBanner(
                        title: "Ready to seat players",
                        message: "When everyone is at the table, tap Seat Players to create tables for Round \(viewModel.currentRound).",
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

                achievementsPreviewSection
            }

            Section {
                VStack(spacing: 16) {
                    EmptyStateView(
                        message: "No tables yet",
                        hint: "Seat players into tables of four for Round \(viewModel.currentRound)."
                    )
                    PrimaryActionButton(
                        title: viewModel.seatPlayersButtonTitle,
                        action: seatPlayersWithFeedback,
                        isDisabled: !viewModel.canSeatPlayers,
                        accessibilityLabel: viewModel.seatPlayersButtonTitle,
                        accessibilityIdentifier: "Seat Players"
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
                        message: "When everyone is at the table, tap Seat Players to create tables for Round \(viewModel.currentRound).",
                        onDismiss: { onDismissSeatPlayersCoachMark?() }
                    )
                }

                EmptyStateView(
                    message: "No tables yet",
                    hint: "Seat players into tables of four for Round \(viewModel.currentRound)."
                )

                PrimaryActionButton(
                    title: viewModel.seatPlayersButtonTitle,
                    action: seatPlayersWithFeedback,
                    isDisabled: !viewModel.canSeatPlayers,
                    accessibilityLabel: viewModel.seatPlayersButtonTitle,
                    accessibilityIdentifier: "Seat Players"
                )
                .frame(maxWidth: 360)
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
    private func seatingsReadyList(includeSidebarSections: Bool) -> some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadSeatingsReadyContent
        } else {
            seatingsReadyPhoneList(includeSidebarSections: includeSidebarSections)
        }
    }

    @ViewBuilder
    private func seatingsReadyPhoneList(includeSidebarSections: Bool) -> some View {
        List {
            if includeSidebarSections {
                if let hint = viewModel.tableLayoutHint {
                    Section {
                        HintText(message: hint)
                    }
                }

                achievementsPreviewSection
            }

            Section {
                HintText(message: "Review who's at each table, then start scoring.")
            }

            Section("Tables for Round \(viewModel.currentRound)") {
                ForEach(Array(viewModel.pods.enumerated()), id: \.offset) { index, pod in
                    TableSeatingCard(
                        tableNumber: index + 1,
                        playerNames: pod.map { viewModel.displayName(for: $0) }
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var ipadSeatingsReadyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.pods.count == 1 {
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
                        tableCount: viewModel.pods.count,
                        horizontalSizeClass: horizontalSizeClass
                    ),
                    alignment: .leading,
                    spacing: 16
                ) {
                    ForEach(Array(viewModel.pods.enumerated()), id: \.offset) { index, pod in
                        TableSeatingCard(
                            tableNumber: index + 1,
                            playerNames: pod.map { viewModel.displayName(for: $0) },
                            style: .card
                        )
                    }
                }

                if viewModel.pods.count == 1 {
                    Spacer(minLength: 32)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: viewModel.pods.count == 1 ? 520 : nil, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Scoring

    @ViewBuilder
    private func scoringPhase(includeBonusesInList: Bool) -> some View {
        if usesSidebarLayout && !includeBonusesInList {
            ipadScoringContent
        } else {
            scoringPhasePhoneList(includeBonusesInList: includeBonusesInList)
        }
    }

    @ViewBuilder
    private func scoringPhasePhoneList(includeBonusesInList: Bool) -> some View {
        let tableIndex = viewModel.currentScoringTableIndex
        let players = viewModel.playersForTable(at: tableIndex)

        List {
            Section {
                scoringProgressHeader(tableIndex: tableIndex)
            }

            if includeBonusesInList,
               viewModel.achievementsOnThisWeek,
               !viewModel.activeAchievements.isEmpty {
                TableBonusesSection(
                    achievements: viewModel.activeAchievements,
                    players: players,
                    displayName: viewModel.displayName(for:),
                    isChecked: viewModel.isAchievementChecked(playerId:achievementId:),
                    isDisabled: viewModel.isAchievementCheckDisabled(playerId:achievementId:),
                    onToggle: viewModel.toggleAchievementCheck(playerId:achievementId:)
                )
            }

            Section {
                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    TableRankRow(
                        rank: index + 1,
                        name: viewModel.displayName(for: player),
                        placementLabel: viewModel.placementLabel(for: index + 1),
                        canMoveUp: index > 0,
                        canMoveDown: index < players.count - 1,
                        onMoveUp: { viewModel.movePlayerUp(inTable: tableIndex, at: index) },
                        onMoveDown: { viewModel.movePlayerDown(inTable: tableIndex, at: index) }
                    )
                }
                .onMove { source, destination in
                    guard let from = source.first else { return }
                    viewModel.movePlayerInTable(at: tableIndex, from: from, to: destination)
                }
            } header: {
                Text("Finish order")
            } footer: {
                Text("Best finish at the top — drag or use the arrows.")
                    .font(.caption)
            }

            if viewModel.pods.count > 1 {
                Section("All tables") {
                    ForEach(viewModel.pods.indices, id: \.self) { index in
                        Button {
                            viewModel.selectScoringTable(index)
                        } label: {
                            HStack {
                                Text("Table \(index + 1)")
                                Spacer()
                                if viewModel.isTableConfirmed(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                } else if index == tableIndex {
                                    Text("Scoring")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityLabel(
                            "Table \(index + 1)\(viewModel.isTableConfirmed(index) ? ", scored" : index == tableIndex ? ", scoring now" : "")"
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(.active))
    }

    @ViewBuilder
    private var ipadScoringContent: some View {
        let tableIndex = viewModel.currentScoringTableIndex
        let players = viewModel.playersForTable(at: tableIndex)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                scoringProgressHeader(tableIndex: tableIndex)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Finish order")
                        .font(.headline)
                    Text("Best finish at the top — drag or use the arrows.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                            TableRankRow(
                                rank: index + 1,
                                name: viewModel.displayName(for: player),
                                placementLabel: viewModel.placementLabel(for: index + 1),
                                canMoveUp: index > 0,
                                canMoveDown: index < players.count - 1,
                                onMoveUp: { viewModel.movePlayerUp(inTable: tableIndex, at: index) },
                                onMoveDown: { viewModel.movePlayerDown(inTable: tableIndex, at: index) }
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)

                            if index < players.count - 1 {
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                if viewModel.pods.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All tables")
                            .font(.headline)
                        ForEach(viewModel.pods.indices, id: \.self) { index in
                            Button {
                                viewModel.selectScoringTable(index)
                            } label: {
                                HStack {
                                    Text("Table \(index + 1)")
                                    Spacer()
                                    if viewModel.isTableConfirmed(index) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    } else if index == tableIndex {
                                        Text("Scoring")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .accessibilityLabel(
                                "Table \(index + 1)\(viewModel.isTableConfirmed(index) ? ", scored" : index == tableIndex ? ", scoring now" : "")"
                            )
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private func scoringProgressHeader(tableIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Table \(tableIndex + 1) of \(viewModel.pods.count)")
                .font(.headline)
            Text("\(viewModel.scoredTablesCount) of \(viewModel.pods.count) tables scored")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Review

    @ViewBuilder
    private func reviewPhaseList(includeSidebarSections: Bool) -> some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadReviewContent
        } else {
            reviewPhasePhoneList(includeSidebarSections: includeSidebarSections)
        }
    }

    @ViewBuilder
    private func reviewPhasePhoneList(includeSidebarSections: Bool) -> some View {
        List {
            Section {
                HintText(message: "Everything looks right? Finish the round to save scores.")
            }

            if includeSidebarSections, viewModel.hasWeeklyStandingsToShow {
                weeklyStandingsPreviewSection
            }

            Section("Round \(viewModel.currentRound) results") {
                ForEach(viewModel.pods.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Table \(index + 1)")
                            .font(.headline)
                        ForEach(viewModel.placementSummary(forTable: index), id: \.name) { row in
                            HStack {
                                Text(row.name)
                                Spacer()
                                Text(viewModel.placementLabel(for: row.place))
                                    .foregroundStyle(row.place == 1 ? AppConstants.AccessibleColors.activeStatus : .secondary)
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private var ipadReviewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Everything looks right? Finish the round to save scores.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Round \(viewModel.currentRound) results")
                    .font(.title3.weight(.semibold))

                LazyVGrid(
                    columns: AdaptiveLayout.tableCardGridColumns(
                        tableCount: viewModel.pods.count,
                        horizontalSizeClass: horizontalSizeClass
                    ),
                    alignment: .leading,
                    spacing: 16
                ) {
                    ForEach(viewModel.pods.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Table \(index + 1)")
                                .font(.headline)

                            ForEach(viewModel.placementSummary(forTable: index), id: \.name) { row in
                                HStack {
                                    Text(row.name)
                                    Spacer()
                                    Text(viewModel.placementLabel(for: row.place))
                                        .foregroundStyle(row.place == 1 ? AppConstants.AccessibleColors.activeStatus : .secondary)
                                }
                                .font(.subheadline)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Shared sections

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
                    Text(viewModel.displayName(for: item.player))
                    Spacer()
                    Text("\(item.points.total) pts")
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Rank \(index + 1), \(viewModel.displayName(for: item.player)), \(item.points.total) points")
            }

            if viewModel.weeklyStandings.filter({ $0.points.total > 0 }).count > viewModel.inlineWeeklyStandings.count {
                Button("See full standings") {
                    viewModel.selectedStandingsWeek = viewModel.currentWeek
                    viewModel.setTab(.standings)
                }
                .font(.subheadline)
                .accessibilityLabel("See full standings for week \(viewModel.currentWeek)")
            }
        } header: {
            Text("Week \(viewModel.currentWeek) leaderboard")
        }
    }

    @ViewBuilder
    private var achievementsPreviewPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This week's achievements")
                .font(.headline)

            Group {
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
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private var weeklyStandingsPreviewPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Week \(viewModel.currentWeek) leaderboard")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(Array(viewModel.inlineWeeklyStandings.enumerated()), id: \.element.player.id) { index, item in
                    HStack {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(width: 24, alignment: .leading)
                        Text(viewModel.displayName(for: item.player))
                        Spacer()
                        Text("\(item.points.total) pts")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Rank \(index + 1), \(viewModel.displayName(for: item.player)), \(item.points.total) points")
                }

                if viewModel.weeklyStandings.filter({ $0.points.total > 0 }).count > viewModel.inlineWeeklyStandings.count {
                    Button("See full standings") {
                        viewModel.selectedStandingsWeek = viewModel.currentWeek
                        viewModel.setTab(.standings)
                    }
                    .font(.subheadline)
                    .accessibilityLabel("See full standings for week \(viewModel.currentWeek)")
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private var scoringBonusesPanel: some View {
        let tableIndex = viewModel.currentScoringTableIndex
        let players = viewModel.playersForTable(at: tableIndex)

        VStack(alignment: .leading, spacing: 12) {
            Text("Bonuses")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.activeAchievements, id: \.id) { achievement in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: achievement.iconName)
                                .foregroundStyle(Color("BrandGold"))
                            Text(achievement.name)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("+\(achievement.points)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        ForEach(players, id: \.id) { player in
                            Toggle(isOn: Binding(
                                get: { viewModel.isAchievementChecked(playerId: player.id, achievementId: achievement.id) },
                                set: { _ in viewModel.toggleAchievementCheck(playerId: player.id, achievementId: achievement.id) }
                            )) {
                                Text(viewModel.displayName(for: player))
                                    .font(.body)
                            }
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                            .disabled(viewModel.isAchievementCheckDisabled(playerId: player.id, achievementId: achievement.id))
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Sticky actions

    @ViewBuilder
    private var roundStickyActionsBar: some View {
        let stacked = AdaptiveLayout.usesStackedPodsActionBar(dynamicType: dynamicTypeSize)

        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 12) {
                if stacked {
                    primaryRoundActions(stacked: true)
                    roundMoreMenu(stacked: true)
                } else {
                    HStack(spacing: 12) {
                        primaryRoundActions(stacked: false)
                        roundMoreMenu(stacked: false)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(.bar)
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
                action: {
                    viewModel.reopenScoring()
                    onShowToast("Update table results, then review again")
                },
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

    @ViewBuilder
    private func roundMoreMenu(stacked: Bool) -> some View {
        Menu {
            if viewModel.canEdit {
                Button("Edit Last Round") {
                    onRequestEditLastRound()
                }
                .accessibilityIdentifier("Edit Last Round")
            }
            Button("Edit Attendance") {
                viewModel.goToAttendance()
            }
            .accessibilityIdentifier("Edit Attendance")
        } label: {
            Label("More", systemImage: "ellipsis.circle")
                .font(.subheadline.weight(.medium))
                .frame(
                    maxWidth: stacked ? .infinity : nil,
                    minHeight: AppConstants.UI.minTouchTargetHeight
                )
                .padding(.horizontal, stacked ? 0 : 12)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("More actions")
        .accessibilityIdentifier("roundMoreMenu")
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
}

// MARK: - Shared rank row (used in scoring list)

private struct TableRankRow: View {
    let rank: Int
    let name: String
    let placementLabel: String
    let canMoveUp: Bool
    let canMoveDown: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(placementLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(rank == 1 ? AppConstants.AccessibleColors.activeStatus : .secondary)
                .frame(width: 36, alignment: .leading)

            Text(name)
                .font(.body)

            Spacer()

            VStack(spacing: 4) {
                Button(action: onMoveUp) {
                    Image(systemName: "chevron.up")
                }
                .disabled(!canMoveUp)
                .accessibilityLabel("Move \(name) up")

                Button(action: onMoveDown) {
                    Image(systemName: "chevron.down")
                }
                .disabled(!canMoveDown)
                .accessibilityLabel("Move \(name) down")
            }
            .buttonStyle(.borderless)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placementLabel), \(name)")
        .accessibilityHint("Drag to reorder, or use the up and down buttons")
    }
}
