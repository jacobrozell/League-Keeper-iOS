import SwiftUI

/// Scoring phase of the round flow.
struct RoundScoringView: View {
    @Bindable var viewModel: TournamentDetailViewModel
    var usesSidebarLayout: Bool
    var includeBonusesInList: Bool

    var body: some View {
        if usesSidebarLayout && !includeBonusesInList {
            ipadScoringContent
        } else {
            scoringPhasePhoneList
        }
    }

    @ViewBuilder
    private var scoringPhasePhoneList: some View {
        let tableIndex = viewModel.currentScoringTableIndex
        let players = viewModel.playersForTable(at: tableIndex)

        List {
            if viewModel.pods.count > 1 {
                Section {
                    HintText(message: "Score one table at a time. Use All tables below or Next Table to switch.")
                }
            }

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
                        scoringTablePickerRow(index: index, currentTableIndex: tableIndex)
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
                            scoringTablePickerRow(index: index, currentTableIndex: tableIndex, style: .card)
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

    private enum TablePickerStyle {
        case list
        case card
    }

    @ViewBuilder
    private func scoringTablePickerRow(
        index: Int,
        currentTableIndex: Int,
        style: TablePickerStyle = .list
    ) -> some View {
        let label = "Table \(index + 1)\(viewModel.isTableConfirmed(index) ? ", scored" : index == currentTableIndex ? ", scoring now" : "")"

        Group {
            switch style {
            case .list:
                Button {
                    viewModel.selectScoringTable(index)
                } label: {
                    HStack {
                        Text("Table \(index + 1)")
                        Spacer()
                        scoringTableStatus(index: index, currentTableIndex: currentTableIndex)
                    }
                }
            case .card:
                Button {
                    viewModel.selectScoringTable(index)
                } label: {
                    HStack {
                        Text("Table \(index + 1)")
                        Spacer()
                        scoringTableStatus(index: index, currentTableIndex: currentTableIndex)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private func scoringTableStatus(index: Int, currentTableIndex: Int) -> some View {
        if viewModel.isTableConfirmed(index) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.secondary)
        } else if index == currentTableIndex {
            Text("Scoring")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}
