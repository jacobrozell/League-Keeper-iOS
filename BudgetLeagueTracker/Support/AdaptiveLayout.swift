import SwiftUI

/// Shared size-class and Dynamic Type helpers for adaptive navigation and list chrome.
enum AdaptiveLayout {
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

    /// Use menu-style section pickers when vertical space is tight (e.g. landscape on iPhone).
    static func usesMenuSectionPicker(verticalSizeClass: UserInterfaceSizeClass?) -> Bool {
        verticalSizeClass == .compact
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

extension View {
    /// Scrollable empty states with tab-bar clearance for accessibility text sizes.
    func adaptiveEmptyStateLayout() -> some View {
        modifier(AdaptiveEmptyStateLayout())
    }
}
