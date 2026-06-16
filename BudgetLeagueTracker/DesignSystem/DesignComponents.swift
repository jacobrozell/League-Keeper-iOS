import SwiftUI

/// A single stat tile: serif value over a condensed label.
struct StatTile: View {
    let value: Int
    let label: String
    var accent: Bool = false

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(accent ? Color(hex: palette.gold) : .primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value)")
    }
}

/// Status capsule for tournament/player states — mirrors MiniMuster `StateChip`.
struct StatusChip: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let label: String
    var colorHex: String = "#34C759"
    var accessibilityPrefix: String = "Status"

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
            .padding(.horizontal, 8).padding(.vertical, 5)
            .foregroundStyle(Color(hex: colorHex))
            .background(Color(hex: colorHex).opacity(0.12), in: Capsule())
            .overlay(Capsule().stroke(Color(hex: colorHex).opacity(0.5)))
            .accessibilityLabel("\(accessibilityPrefix): \(label)")
    }
}

/// Card-style section container used on stats and detail screens.
struct BrandedSectionCard<Content: View>: View {
    @Environment(\.palette) private var palette
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(Color(hex: palette.surface), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color(hex: palette.line).opacity(0.5), lineWidth: 0.5)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

private struct BrandedScreenBackground: ViewModifier {
    @Environment(\.palette) private var palette

    func body(content: Content) -> some View {
        content
            .background(Color(hex: palette.bg2).ignoresSafeArea())
    }
}

extension View {
    /// Warm parchment background behind grouped lists and scroll content.
    func brandedScreenBackground() -> some View {
        modifier(BrandedScreenBackground())
    }
}
