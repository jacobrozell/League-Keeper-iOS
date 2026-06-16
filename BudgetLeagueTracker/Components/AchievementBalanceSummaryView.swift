import SwiftUI

/// Host-facing balance guidance for the achievement catalog.
struct AchievementBalanceSummaryView: View {
    let summary: AchievementBalanceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("League balance", systemImage: "scalemass.fill")
                .font(.headline)

            Text("\(summary.catalogCount) in catalog · \(summary.alwaysOnCount) every week · ~\(summary.expectedActivePerWeek) active per week")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(String(format: "Average value: %.1f pts per achievement", summary.averagePoints))
                .font(.caption)
                .foregroundStyle(.secondary)

            if let guidance = summary.guidanceMessage {
                Text(guidance)
                    .font(.caption)
                    .foregroundStyle(AppConstants.AccessibleColors.statOrange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AchievementBalanceSummaryView(
        summary: AchievementBalanceSummary(
            catalogCount: 8,
            alwaysOnCount: 2,
            expectedActivePerWeek: 4,
            averagePoints: 1.8,
            guidanceMessage: "Add a few more for variety each week."
        )
    )
    .padding()
}
