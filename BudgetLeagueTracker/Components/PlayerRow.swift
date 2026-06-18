import SwiftUI

/// Defines the different display modes for PlayerRow.
enum PlayerRowMode {
    /// Display only: shows name and optional subtitle (e.g., for Stats view)
    case display(
        subtitle: String?,
        showAvatar: Bool = false,
        playerId: String? = nil,
        rank: Int? = nil,
        recentPlacements: [Int] = [],
        sparklinePoints: [Double] = []
    )

    /// With remove button: shows name and a trash button (e.g., for Add Players view)
    case removable(onRemove: () -> Void)

    /// With toggle: shows name and a toggle for present/absent (e.g., for Attendance view)
    case toggleable(isOn: Binding<Bool>)
}

/// A versatile player row component used across multiple views.
/// Supports display, removable, and toggleable modes.
struct PlayerRow: View {
    let name: String
    let mode: PlayerRowMode

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            switch mode {
            case .display(let subtitle, let showAvatar, let playerId, let rank, let recentPlacements, let sparklinePoints):
                displayContent(
                    subtitle: subtitle,
                    showAvatar: showAvatar,
                    playerId: playerId,
                    rank: rank,
                    recentPlacements: recentPlacements,
                    sparklinePoints: sparklinePoints
                )

            case .removable(let onRemove):
                removableContent(onRemove: onRemove)

            case .toggleable(let isOn):
                toggleableContent(isOn: isOn)
            }
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
    }

    @ViewBuilder
    private func displayContent(
        subtitle: String?,
        showAvatar: Bool,
        playerId: String?,
        rank: Int?,
        recentPlacements: [Int],
        sparklinePoints: [Double]
    ) -> some View {
        if showAvatar {
            PlayerAvatarView(name: name, playerId: playerId)
        }

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(.system(.headline, design: .serif))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                if let rank {
                    Text("#\(rank)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppConstants.AccessibleColors.winnerAccent)
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            if !recentPlacements.isEmpty {
                PlayerFormDotsView(placements: recentPlacements)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility5)

        Spacer(minLength: 8)

        if sparklinePoints.count >= 2 {
            PlayerSparklineView(points: sparklinePoints)
        }
    }

    @ViewBuilder
    private func removableContent(onRemove: @escaping () -> Void) -> some View {
        Text(name)
            .font(.body)
        Spacer()
        Button(role: .destructive, action: onRemove) {
            Image(systemName: "trash")
        }
        .accessibilityLabel("Remove \(name)")
    }

    @ViewBuilder
    private func toggleableContent(isOn: Binding<Bool>) -> some View {
        Toggle(name, isOn: isOn)
            .accessibilityLabel("Mark \(name) as present")
            .accessibilityValue(isOn.wrappedValue ? "Present" : "Absent")
            .accessibilityIdentifier("toggle-\(name)")
    }
}

// MARK: - Preview

#Preview("Display Mode") {
    List {
        PlayerRow(
            name: "Alice",
            mode: .display(
                subtitle: "142 pts • 18 games • 6 wins",
                showAvatar: true,
                playerId: "1",
                rank: 2,
                recentPlacements: [1, 2, 1, 3],
                sparklinePoints: [4, 8, 12, 18]
            )
        )
        PlayerRow(name: "Bob", mode: .display(subtitle: nil))
    }
    .listStyle(.insetGrouped)
}

#Preview("Removable Mode") {
    List {
        PlayerRow(name: "Alice", mode: .removable(onRemove: {}))
        PlayerRow(name: "Bob", mode: .removable(onRemove: {}))
    }
    .listStyle(.insetGrouped)
}

#Preview("Toggleable Mode") {
    List {
        PlayerRow(name: "Alice", mode: .toggleable(isOn: .constant(true)))
        PlayerRow(name: "Bob", mode: .toggleable(isOn: .constant(false)))
    }
    .listStyle(.insetGrouped)
}
