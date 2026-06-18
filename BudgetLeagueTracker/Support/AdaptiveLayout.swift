import SwiftUI
import UIKit

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

    /// iPad landscape: regular width with limited vertical space (not iPhone landscape).
    @MainActor
    static func usesCompactVerticalChrome(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        guard verticalSizeClass == .compact else { return false }
        guard horizontalSizeClass == .regular else { return false }
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Tighter vertical padding for chrome bars on iPad landscape.
    @MainActor
    static func chromeVerticalPadding(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> CGFloat {
        usesCompactVerticalChrome(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) ? 4 : 8
    }

    /// Prefer vertical row layout when text is large or horizontal space is tight.
    @MainActor
    static func usesStackedRowLayout(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        horizontalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        if dynamicType.isAccessibilitySize { return true }
        guard verticalSizeClass == .compact else { return false }
        return !isPadLandscape(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Prefer menu-style pickers when labels won't fit segmented controls (landscape or large text).
    @MainActor
    static func usesMenuPickerStyle(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        horizontalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        if dynamicType.isAccessibilitySize { return true }
        guard verticalSizeClass == .compact else { return false }
        return !isPadLandscape(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Use menu-style section pickers when segmented labels won't fit (large Dynamic Type only).
    static func usesMenuSectionPicker(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        dynamicType.isAccessibilitySize
    }

    /// Stack the pods action bar vertically in iPhone landscape or at large accessibility text sizes.
    @MainActor
    static func usesStackedPodsActionBar(
        dynamicType: DynamicTypeSize,
        verticalSizeClass: UserInterfaceSizeClass? = nil,
        horizontalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        if dynamicType.isAccessibilitySize { return true }
        guard verticalSizeClass == .compact else { return false }
        return !isPadLandscape(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    @MainActor
    private static func isPadLandscape(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> Bool {
        usesCompactVerticalChrome(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Regular-width layout: iPad at regular horizontal size, excluding iPhone landscape.
    /// iPhone landscape reports regular horizontal + compact vertical — treat as phone layout.
    @MainActor
    static func usesRegularWidthLayout(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        guard horizontalSizeClass == .regular else { return false }
        if verticalSizeClass == .compact {
            return UIDevice.current.userInterfaceIdiom == .pad
        }
        return true
    }

    /// Whether content should use the readable max width (iPad and other regular-width layouts).
    @MainActor
    static func usesReadableContentWidth(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        usesRegularWidthLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Side-by-side sidebar + main content on iPad and other regular-width layouts.
    @MainActor
    static func usesTwoColumnLayout(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        usesRegularWidthLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Two-column grid for player toggle lists on regular-width layouts.
    @MainActor
    static func usesTwoColumnPlayerGrid(
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> Bool {
        usesRegularWidthLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    /// Grid columns for table cards on regular-width layouts.
    @MainActor
    static func tableCardGridColumns(
        tableCount: Int,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass? = nil
    ) -> [GridItem] {
        guard usesRegularWidthLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) else {
            return [GridItem(.flexible())]
        }
        let columnCount = tableCount <= 1 ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
}

private struct AdaptiveContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    func body(content: Content) -> some View {
        if AdaptiveLayout.usesReadableContentWidth(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) {
            content
                .frame(maxWidth: AdaptiveLayout.contentMaxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ViewBuilder let sidebar: () -> Sidebar
    @ViewBuilder let main: () -> Main

    var body: some View {
        if AdaptiveLayout.usesTwoColumnLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) {
            HStack(alignment: .top, spacing: AdaptiveLayout.columnSpacing) {
                sidebar()
                    .frame(width: AdaptiveLayout.sidebarWidth, alignment: .top)
                    .frame(maxHeight: .infinity, alignment: .top)
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

    /// Insets grouped list scroll content so lists center on iPad like other screens.
    func adaptiveListLayout() -> some View {
        modifier(AdaptiveListSideInset())
    }

    /// Scrollable empty states with tab-bar clearance for accessibility text sizes.
    func adaptiveEmptyStateLayout() -> some View {
        modifier(AdaptiveEmptyStateLayout())
    }
}

private struct AdaptiveListSideInset: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var sideInset: CGFloat = 0

    private var appliesInset: Bool {
        AdaptiveLayout.usesReadableContentWidth(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    func body(content: Content) -> some View {
        content
            .background {
                if appliesInset {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                sideInset = Self.inset(for: proxy.size.width)
                            }
                            .onChange(of: proxy.size.width) { _, width in
                                sideInset = Self.inset(for: width)
                            }
                    }
                }
            }
            .contentMargins(.horizontal, appliesInset ? sideInset : 0, for: .scrollContent)
    }

    private static func inset(for width: CGFloat) -> CGFloat {
        max(0, (width - AdaptiveLayout.contentMaxWidth) / 2)
    }
}
