import SwiftUI

/// Points tier picker with placement context copy.
struct AchievementPointsTierPicker: View {
    @Binding var points: Int
    @Binding var usesCustomPoints: Bool

    @FocusState private var isCustomPointsFocused: Bool
    @State private var customPointsText = ""

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
                HStack {
                    Text("Points")
                        .font(.body)
                    Spacer()
                    TextField("0", text: $customPointsText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                        .focused($isCustomPointsFocused)
                        .accessibilityLabel("Custom points")
                        .accessibilityIdentifier("customPointsField")
                        .onChange(of: customPointsText) { _, newValue in
                            applyCustomPointsText(newValue)
                        }
                }
                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
            }
        }
        .onChange(of: usesCustomPoints) { _, isCustom in
            if isCustom {
                customPointsText = "\(points)"
                isCustomPointsFocused = true
            }
        }
        .onAppear {
            if usesCustomPoints {
                customPointsText = "\(points)"
            }
        }
        .onChange(of: points) { _, newValue in
            guard usesCustomPoints else { return }
            let text = "\(newValue)"
            if customPointsText != text {
                customPointsText = text
            }
        }
    }

    private func tierBackground(for tier: AchievementPointsTier) -> Color {
        if !usesCustomPoints && points == tier.points {
            return Color("BrandGold").opacity(0.2)
        }
        return Color(.tertiarySystemBackground)
    }

    private func applyCustomPointsText(_ text: String) {
        let digits = text.filter(\.isNumber)
        if digits != text {
            customPointsText = digits
            return
        }
        guard let parsed = Int(digits) else {
            points = AppConstants.Achievement.pointsRange.lowerBound
            return
        }
        points = min(max(parsed, AppConstants.Achievement.pointsRange.lowerBound), AppConstants.Achievement.pointsRange.upperBound)
        if digits != "\(points)" {
            customPointsText = "\(points)"
        }
    }
}

#Preview {
    Form {
        AchievementPointsTierPicker(points: .constant(2), usesCustomPoints: .constant(false))
    }
}
