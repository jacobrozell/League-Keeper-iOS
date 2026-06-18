import SwiftUI

/// A single stat tile: serif value over a condensed label.
struct StatTile: View {
    let value: Int
    let label: String
    var accent: Bool = false

    @Environment(\.palette) private var palette
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var largeText: Bool { dynamicTypeSize.isAccessibilitySize }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(accent ? Color(hex: palette.gold) : .primary)
                .minimumScaleFactor(largeText ? 1.0 : 0.8)
                .lineLimit(largeText ? 2 : 1)
            Text(label)
                .font(largeText ? .caption : .caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(largeText ? 1.0 : 0.85)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: largeText ? 88 : 72)
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

/// Layered brand gradient used on splash and tab screens.
struct BrandedGradientBackground: View {
    @Environment(\.palette) private var palette

    var body: some View {
        ZStack {
            Color(hex: palette.bg)
                .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: palette.gold).opacity(0.18),
                    Color(hex: palette.bg).opacity(0),
                ],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: palette.blood).opacity(0.08),
                    Color(hex: palette.bg).opacity(0),
                ],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 320
            )
            .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(hex: palette.bg).opacity(0),
                    Color(hex: palette.bg2).opacity(0.55),
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

/// Pinned bottom chrome for primary actions (attendance confirm, round scoring).
struct StickyBottomActionBar<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ViewBuilder let content: () -> Content

    var body: some View {
        let chromePadding = AdaptiveLayout.chromeVerticalPadding(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )

        VStack(spacing: 0) {
            Divider()
            content()
                .padding(.horizontal)
                .padding(.vertical, chromePadding)
        }
        .frame(maxWidth: .infinity)
        .background(.bar)
        .shadow(color: .black.opacity(0.04), radius: 4, y: -2)
    }
}

/// Row fill for inset grouped lists on branded backgrounds.
struct BrandedListRowBackground: View {
    @Environment(\.palette) private var palette

    var body: some View {
        Color(hex: palette.surface)
    }
}

/// Circular primary action button anchored above the tab bar.
struct FloatingActionButton: View {
    let systemImage: String
    let accessibilityLabel: String
    var accessibilityIdentifier: String?
    let action: () -> Void

    var body: some View {
        let button = Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(minWidth: 56, minHeight: 56)
                .background(Color("AccentColor"), in: Circle())
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        }
        .accessibilityLabel(accessibilityLabel)

        if let accessibilityIdentifier {
            button.accessibilityIdentifier(accessibilityIdentifier)
        } else {
            button
        }
    }
}

private struct BrandedScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            BrandedGradientBackground()
            content
        }
    }
}

/// Full-width branded background with a readable content column on iPad.
private struct BrandedAdaptiveScreen: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    func body(content: Content) -> some View {
        ZStack {
            BrandedGradientBackground()
            if AdaptiveLayout.usesReadableContentWidth(
                horizontalSizeClass: horizontalSizeClass,
                verticalSizeClass: verticalSizeClass
            ) {
                content
                    .frame(maxWidth: AdaptiveLayout.contentMaxWidth, maxHeight: .infinity, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                content
            }
        }
    }
}

private struct BrandedListChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .adaptiveListLayout()
    }
}

private struct BrandedInsetListRow: ViewModifier {
    func body(content: Content) -> some View {
        content.listRowBackground(BrandedListRowBackground())
    }
}

extension View {
    /// Warm parchment background behind grouped lists and scroll content.
    func brandedScreenBackground() -> some View {
        modifier(BrandedScreenBackground())
    }

    /// Branded background edge-to-edge with readable content width on iPad.
    func brandedAdaptiveScreen() -> some View {
        modifier(BrandedAdaptiveScreen())
    }

    /// Inset grouped list with scroll chrome hidden so the branded background shows through.
    func brandedListChrome() -> some View {
        modifier(BrandedListChrome())
    }

    /// Surface-colored row background for lists on branded screens.
    func brandedInsetListRow() -> some View {
        modifier(BrandedInsetListRow())
    }
}
