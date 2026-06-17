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

    @Test("two-column layout on regular horizontal size class")
    func twoColumnOnRegular() {
        #expect(AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: .regular))
        #expect(!AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: .compact))
        #expect(AdaptiveLayout.usesTwoColumnPlayerGrid(horizontalSizeClass: .regular))
        #expect(!AdaptiveLayout.usesTwoColumnPlayerGrid(horizontalSizeClass: .compact))
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

    @Test("keeps segmented section picker in landscape at default text")
    func segmentedSectionPickerInLandscape() {
        #expect(
            !AdaptiveLayout.usesMenuSectionPicker(
                dynamicType: .large,
                verticalSizeClass: .compact
            )
        )
    }

    @Test("stacks pods action bar for accessibility text sizes")
    func stackedPodsActionBarForAccessibility() {
        #expect(AdaptiveLayout.usesStackedPodsActionBar(dynamicType: .accessibility1))
        #expect(!AdaptiveLayout.usesStackedPodsActionBar(dynamicType: .large))
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

    @Test("layout width tokens")
    func layoutWidthTokens() {
        #expect(AdaptiveLayout.contentMaxWidth == 920)
        #expect(AdaptiveLayout.sidebarWidth == 320)
        #expect(AdaptiveLayout.columnSpacing == 20)
    }

    @Test("table card grid columns")
    func tableCardGridColumns() {
        #expect(AdaptiveLayout.tableCardGridColumns(tableCount: 0, horizontalSizeClass: .compact).count == 1)
        #expect(AdaptiveLayout.tableCardGridColumns(tableCount: 4, horizontalSizeClass: .compact).count == 1)
        #expect(AdaptiveLayout.tableCardGridColumns(tableCount: 1, horizontalSizeClass: .regular).count == 1)
        #expect(AdaptiveLayout.tableCardGridColumns(tableCount: 2, horizontalSizeClass: .regular).count == 2)
        #expect(AdaptiveLayout.tableCardGridColumns(tableCount: 6, horizontalSizeClass: .regular).count == 2)
    }
}
