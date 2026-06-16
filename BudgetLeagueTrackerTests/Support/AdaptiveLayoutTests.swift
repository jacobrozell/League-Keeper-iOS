import SwiftUI
import Testing
@testable import BudgetLeagueTracker

@Suite("AdaptiveLayout")
struct AdaptiveLayoutTests {

    @Test("uses stacked row layout in landscape compact height")
    func stackedInLandscape() {
        #expect(
            AdaptiveLayout.usesStackedRowLayout(
                dynamicType: .large,
                verticalSizeClass: .compact
            )
        )
    }

    @Test("uses stacked row layout for accessibility text sizes")
    func stackedForAccessibilityText() {
        #expect(
            AdaptiveLayout.usesStackedRowLayout(
                dynamicType: .accessibility1,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("does not stack in portrait at default text size")
    func portraitDefaultNotStacked() {
        #expect(
            !AdaptiveLayout.usesStackedRowLayout(
                dynamicType: .large,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("readable width on regular horizontal size class")
    func readableWidthOnRegular() {
        #expect(AdaptiveLayout.usesReadableContentWidth(horizontalSizeClass: .regular))
        #expect(!AdaptiveLayout.usesReadableContentWidth(horizontalSizeClass: .compact))
    }

    @Test("uses menu section picker for accessibility text sizes")
    func menuPickerForAccessibilityText() {
        #expect(
            AdaptiveLayout.usesMenuSectionPicker(
                dynamicType: .accessibility1,
                verticalSizeClass: .regular
            )
        )
        #expect(
            AdaptiveLayout.usesMenuPickerStyle(
                dynamicType: .accessibility5,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("uses menu picker in landscape compact height at default text")
    func menuPickerInLandscape() {
        #expect(
            AdaptiveLayout.usesMenuPickerStyle(
                dynamicType: .large,
                verticalSizeClass: .compact
            )
        )
    }

    @Test("does not use menu picker in portrait at default text size")
    func portraitDefaultUsesSegmentedStyle() {
        #expect(
            !AdaptiveLayout.usesMenuPickerStyle(
                dynamicType: .large,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("content max width token")
    func contentMaxWidthToken() {
        #expect(AdaptiveLayout.contentMaxWidth == 680)
    }
}
