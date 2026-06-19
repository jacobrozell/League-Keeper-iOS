import SwiftUI

/// Secondary achievement description copy used in scoring and bonus lists.
struct AchievementDescriptionText: View {
    let description: String?

    var body: some View {
        if let description, !description.isEmpty {
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
