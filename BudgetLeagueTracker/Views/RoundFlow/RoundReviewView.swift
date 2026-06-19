import SwiftUI

/// Review phase of the round flow.
struct RoundReviewView: View {
    @Bindable var viewModel: TournamentDetailViewModel
    var usesSidebarLayout: Bool
    var horizontalSizeClass: UserInterfaceSizeClass?
    var includeSidebarSections: Bool

    var body: some View {
        if usesSidebarLayout && !includeSidebarSections {
            ipadReviewContent
        } else {
            reviewPhasePhoneList
        }
    }

    @ViewBuilder
    private var reviewPhasePhoneList: some View {
        List {
            Section {
                HintText(message: "Everything looks right? Finish the round to save scores.")
            }

            if includeSidebarSections, viewModel.hasWeeklyStandingsToShow {
                RoundWeeklyStandingsPreviewSection(viewModel: viewModel)
            }

            Section("Round \(viewModel.currentRound) results") {
                ForEach(viewModel.tables.indices, id: \.self) { index in
                    tableResultsBlock(index: index)
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
                        tableCount: viewModel.tables.count,
                        horizontalSizeClass: horizontalSizeClass
                    ),
                    alignment: .leading,
                    spacing: 16
                ) {
                    ForEach(viewModel.tables.indices, id: \.self) { index in
                        tableResultsBlock(index: index, style: .card)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private enum ResultsStyle {
        case list
        case card
    }

    @ViewBuilder
    private func tableResultsBlock(index: Int, style: ResultsStyle = .list) -> some View {
        switch style {
        case .list:
            VStack(alignment: .leading, spacing: 8) {
                Text("Table \(index + 1)")
                    .font(.headline)
                placementRows(forTable: index)
            }
            .padding(.vertical, 4)

        case .card:
            VStack(alignment: .leading, spacing: 12) {
                Text("Table \(index + 1)")
                    .font(.headline)
                placementRows(forTable: index)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    @ViewBuilder
    private func placementRows(forTable index: Int) -> some View {
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
}
