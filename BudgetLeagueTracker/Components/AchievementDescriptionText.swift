import SwiftUI

/// Secondary achievement description copy used in scoring and bonus lists.
struct AchievementDescriptionText: View {
    enum Style {
        case standard
        case compact
    }

    let description: String?
    var style: Style = .standard

    var body: some View {
        if let description, !description.isEmpty {
            Text(description)
                .font(style == .standard ? .caption : .caption2)
                .foregroundStyle(style == .standard ? .secondary : .tertiary)
                .lineLimit(style == .compact ? 2 : nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
