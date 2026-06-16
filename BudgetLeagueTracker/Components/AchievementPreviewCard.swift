import SwiftUI

/// Live preview of an achievement while editing the form.
struct AchievementPreviewCard: View {
    let name: String
    let achievementDescription: String
    let points: Int
    let alwaysOn: Bool
    let category: AchievementCategory
    let iconName: String
    let exclusivity: AchievementExclusivity

    private var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Achievement Name" : trimmed
    }

    private var displayDescription: String {
        let trimmed = achievementDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Add a short rule players can read at the table." : trimmed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(Color("BrandGold"))
                    .frame(width: 44, height: 44)
                    .background(Color("BrandGold").opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName)
                        .font(.headline)
                    Text(displayDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                Label("+\(points) pts", systemImage: "star.fill")
                    .font(.caption.weight(.semibold))

                Text(alwaysOn ? "Every week" : "Random pool")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())

                Text(category.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            Text(exclusivity.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preview: \(displayName), \(points) points, \(alwaysOn ? "every week" : "random pool")")
    }
}

#Preview {
    AchievementPreviewCard(
        name: "First Blood",
        achievementDescription: "First player to eliminate another player",
        points: 1,
        alwaysOn: false,
        category: .combat,
        iconName: "flame.fill",
        exclusivity: .onePerPod
    )
    .padding()
}
