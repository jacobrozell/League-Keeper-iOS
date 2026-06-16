import SwiftUI

/// Earned achievement badges for a player.
struct PlayerAchievementGallerySection: View {
    let items: [(achievement: Achievement, timesEarned: Int)]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Achievements Earned")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items, id: \.achievement.id) { item in
                    VStack(spacing: 6) {
                        Image(systemName: item.achievement.iconName)
                            .font(.title3)
                            .foregroundStyle(AppConstants.AccessibleColors.achievementAccent)
                        Text(item.achievement.name)
                            .font(.caption.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        Text("×\(item.timesEarned)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(item.achievement.name), earned \(item.timesEarned) times")
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        PlayerAchievementGallerySection(
            items: [
                (achievement: Achievement(name: "First Blood", points: 2), timesEarned: 3)
            ]
        )
        .padding()
    }
}
