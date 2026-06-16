import SwiftUI

/// Points tier picker with placement context copy.
struct AchievementPointsTierPicker: View {
    @Binding var points: Int
    @Binding var usesCustomPoints: Bool

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !usesCustomPoints {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(AchievementPointsTier.allCases) { tier in
                        Button {
                            usesCustomPoints = false
                            points = tier.points
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tier.displayName)
                                    .font(.subheadline.weight(.semibold))
                                Text("+\(tier.points) · \(tier.placementContext)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(tierBackground(for: tier))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tier.displayName), \(tier.points) points")
                        .accessibilityAddTraits(points == tier.points && !usesCustomPoints ? .isSelected : [])
                    }
                }
            }

            Toggle("Custom points", isOn: $usesCustomPoints)

            if usesCustomPoints {
                LabeledStepper(
                    title: "Points",
                    value: $points,
                    range: AppConstants.Achievement.pointsRange
                )
            }
        }
    }

    private func tierBackground(for tier: AchievementPointsTier) -> Color {
        if !usesCustomPoints && points == tier.points {
            return Color("BrandGold").opacity(0.2)
        }
        return Color(.tertiarySystemBackground)
    }
}

#Preview {
    Form {
        AchievementPointsTierPicker(points: .constant(2), usesCustomPoints: .constant(false))
    }
}
