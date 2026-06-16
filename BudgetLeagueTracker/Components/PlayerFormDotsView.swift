import SwiftUI

/// Recent placement form indicator (sports-style dots).
struct PlayerFormDotsView: View {
    let placements: [Int]
    var maxDots: Int = 8

    var body: some View {
        HStack(spacing: 4) {
            ForEach(displayedPlacements.indices, id: \.self) { index in
                Circle()
                    .fill(color(for: displayedPlacements[index]))
                    .frame(width: 10, height: 10)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var displayedPlacements: [Int] {
        Array(placements.prefix(maxDots))
    }

    private var accessibilityLabel: String {
        guard !displayedPlacements.isEmpty else { return "No recent form" }
        let labels = displayedPlacements.map(placementLabel)
        return "Recent form: \(labels.joined(separator: ", "))"
    }

    private func color(for placement: Int) -> Color {
        switch placement {
        case 1: return AppConstants.AccessibleColors.activeStatus
        case 2: return AppConstants.AccessibleColors.placementAccent
        case 3: return AppConstants.AccessibleColors.semanticGray
        default: return Color(.tertiaryLabel)
        }
    }

    private func placementLabel(_ placement: Int) -> String {
        switch placement {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(placement)"
        }
    }
}

#Preview {
    PlayerFormDotsView(placements: [1, 2, 1, 3, 4, 1])
        .padding()
}
