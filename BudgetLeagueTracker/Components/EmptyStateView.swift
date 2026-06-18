import SwiftUI

/// A view displayed when there's no content to show.
/// Branded empty state with optional icon and hint text.
struct EmptyStateView: View {
    let message: String
    var hint: String?
    var systemImage: String = "tray"

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(Color(hex: palette.gold).opacity(0.85))
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(message)
                    .font(.system(.title3, design: .serif).weight(.semibold))
                    .foregroundStyle(Color(hex: palette.ink))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let hint = hint {
                    Text(hint)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .dynamicTypeSize(...DynamicTypeSize.accessibility5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        if let hint, !hint.isEmpty {
            return "\(message). \(hint)"
        }
        return message
    }
}

#Preview {
    ZStack {
        Color("LaunchBackground").ignoresSafeArea()
        VStack(spacing: 32) {
            EmptyStateView(message: "No players yet", systemImage: "person.crop.rectangle.stack")

            EmptyStateView(
                message: "No stats yet",
                hint: "Add players and run pods to see stats.",
                systemImage: "chart.bar"
            )
        }
    }
}
