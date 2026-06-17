import SwiftUI

/// Shared size-class and Dynamic Type helpers for adaptive navigation and list chrome.
enum AdaptiveLayout {
    /// Max content width on regular horizontal size class (iPad, wide layouts).
    static let contentMaxWidth: CGFloat = 920

    /// Fixed width for sidebar panels in two-column iPad layouts.
    static let sidebarWidth: CGFloat = 320

    /// Horizontal gap between sidebar and main column.
    static let columnSpacing: CGFloat = 20

    /// Extra bottom inset so empty-state actions clear the tab bar at large Dynamic Type.
    static func tabBarClearance(for dynamicType: DynamicTypeSize) -> CGFloat {
        if dynamicType >= .accessibility5 { return 220 }
        if dynamicType >= .accessibility3 { return 160 }
        if dynamicType.isAccessibilitySize { return 120 }
        return 88
    }

    /// Prefer vertical row layout when text is large or horizontal space is tight.
    static func usesStackedRowLayout(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        dynamicType.isAccessibilitySize || verticalSizeClass == .compact
    }

    /// Prefer menu-style pickers when labels won't fit segmented controls (landscape or large text).
    static func usesMenuPickerStyle(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        dynamicType.isAccessibilitySize || verticalSizeClass == .compact
    }

    /// Use menu-style section pickers when segmented labels won't fit (large Dynamic Type only).
    static func usesMenuSectionPicker(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        dynamicType.isAccessibilitySize
    }

    /// Stack the pods action bar vertically only at large accessibility text sizes.
    static func usesStackedPodsActionBar(dynamicType: DynamicTypeSize) -> Bool {
        dynamicType.isAccessibilitySize
    }

    /// Whether content should use the readable max width (iPad and other regular-width layouts).
    static func usesReadableContentWidth(horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        horizontalSizeClass == .regular
    }

    /// Side-by-side sidebar + main content on iPad and other regular-width layouts.
    static func usesTwoColumnLayout(horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        horizontalSizeClass == .regular
    }

    /// Two-column grid for player toggle lists on regular-width layouts.
    static func usesTwoColumnPlayerGrid(horizontalSizeClass: UserInterfaceSizeClass?) -> Bool {
        horizontalSizeClass == .regular
    }
}

private struct AdaptiveContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        if AdaptiveLayout.usesReadableContentWidth(horizontalSizeClass: horizontalSizeClass) {
            content
                .frame(maxWidth: AdaptiveLayout.contentMaxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

private struct AdaptiveEmptyStateLayout: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let clearance = AdaptiveLayout.tabBarClearance(for: dynamicTypeSize)
        if dynamicTypeSize.isAccessibilitySize {
            ScrollView {
                content
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 8)
                    .padding(.bottom, clearance)
            }
            .scrollBounceBehavior(.basedOnSize)
        } else {
            content.safeAreaPadding(.bottom, clearance)
        }
    }
}

/// Sidebar + main column on iPad; stacked vertically on iPhone.
struct AdaptiveSidebarLayout<Sidebar: View, Main: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let main: () -> Main

    var body: some View {
        if AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: horizontalSizeClass) {
            HStack(alignment: .top, spacing: AdaptiveLayout.columnSpacing) {
                sidebar()
                    .frame(width: AdaptiveLayout.sidebarWidth, alignment: .top)
                main()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            VStack(spacing: 0) {
                sidebar()
                main()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

extension View {
    /// Centers content in a readable column on iPad (regular horizontal size class).
    /// Pair with a full-width `brandedScreenBackground()` on an ancestor, or use `brandedAdaptiveScreen()`.
    func adaptiveContentWidth() -> some View {
        modifier(AdaptiveContentWidth())
    }

    /// Scrollable empty states with tab-bar clearance for accessibility text sizes.
    func adaptiveEmptyStateLayout() -> some View {
        modifier(AdaptiveEmptyStateLayout())
    }
}
