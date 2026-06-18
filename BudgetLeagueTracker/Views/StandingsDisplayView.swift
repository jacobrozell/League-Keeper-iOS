import SwiftUI
import UIKit

/// Read-only standings for showing on a table-facing iPad or propped-up phone.
struct StandingsDisplayView: View {
    let title: String
    let subtitle: String
    let rows: [StandingsDisplayRow]
    let shareText: String
    var onRefresh: (() -> Void)? = nil
    var onDismiss: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(.largeTitle, design: .serif).weight(.bold))
                            .foregroundStyle(Color(hex: palette.ink))
                        Text(subtitle)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)

                    if rows.isEmpty {
                        Text("No scores yet")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 48)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(rows) { row in
                                displayRow(row)
                            }
                        }
                    }
                }
                .padding(24)
                .adaptiveContentWidth()
            }
            .background(BrandedGradientBackground())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !rows.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        ShareLink(
                            item: shareText,
                            subject: Text("\(title) — \(subtitle)"),
                            message: Text(shareText)
                        ) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share standings")
                        .accessibilityIdentifier("shareStandingsDisplay")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { onDismiss() }
                        .font(.headline)
                }
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                onRefresh?()
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        .accessibilityIdentifier("standingsDisplayView")
    }

    @ViewBuilder
    private func displayRow(_ row: StandingsDisplayRow) -> some View {
        HStack(spacing: 16) {
            if row.rank == 1 {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: palette.gold))
                    .frame(width: 28)
            }

            Text("\(row.rank)")
                .font(.system(size: row.rank == 1 ? 40 : 32, design: .serif).weight(.bold))
                .foregroundStyle(row.rank == 1 ? Color(hex: palette.gold) : .secondary)
                .frame(width: 52, alignment: .trailing)

            Text(row.name)
                .font(.system(row.rank == 1 ? .title : .title2, design: .serif).weight(row.rank == 1 ? .bold : .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 12)

            Text("\(row.totalPoints)")
                .font(.system(row.rank == 1 ? .largeTitle : .title, design: .serif).weight(.bold))
                .foregroundStyle(row.rank == 1 ? Color(hex: palette.gold) : .primary)

            Text("pts")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, row.rank == 1 ? 18 : 14)
        .background(
            row.rank == 1
                ? Color(hex: palette.gold).opacity(0.12)
                : Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(ordinal(row.rank)) place, \(row.name), \(row.totalPoints) points")
    }

    private func ordinal(_ rank: Int) -> String {
        switch rank {
        case 1: return "First"
        case 2: return "Second"
        case 3: return "Third"
        default: return "\(rank)th"
        }
    }
}

struct StandingsDisplayRow: Identifiable, Equatable {
    let id: String
    let rank: Int
    let name: String
    let totalPoints: Int
}

#Preview {
    StandingsDisplayView(
        title: "Spring League",
        subtitle: "Week 2 standings",
        rows: [
            StandingsDisplayRow(id: "1", rank: 1, name: "Alice", totalPoints: 18),
            StandingsDisplayRow(id: "2", rank: 2, name: "Bob", totalPoints: 15),
            StandingsDisplayRow(id: "3", rank: 3, name: "Carol", totalPoints: 12)
        ],
        shareText: "Preview standings",
        onDismiss: {}
    )
}
