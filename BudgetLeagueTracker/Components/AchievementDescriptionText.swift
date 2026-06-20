import SwiftUI

/// Secondary achievement description copy used in scoring and bonus lists.
struct AchievementDescriptionText: View {
    enum Style {
        case standard
        case compact
    }

    let description: String?
    var style: Style = .standard

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if let description, !description.isEmpty {
            Text(description)
                .font(style == .standard ? .caption : .caption2)
                .foregroundStyle(.secondary)
                .lineLimit(compactLineLimit)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var compactLineLimit: Int? {
        guard style == .compact else { return nil }
        return dynamicTypeSize.isAccessibilitySize ? nil : 2
    }
}
