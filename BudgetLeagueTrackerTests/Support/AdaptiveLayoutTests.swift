import SwiftUI
import UIKit
import Testing
@testable import BudgetLeagueTracker

@Suite("AdaptiveLayout")
@MainActor
struct AdaptiveLayoutTests {

    @Test("uses stacked row layout in iPhone landscape compact height")
    func stackedInLandscape() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let stacks = AdaptiveLayout.usesStackedRowLayout(
            dynamicType: .large,
            verticalSizeClass: .compact,
            horizontalSizeClass: .regular
        )
        #expect(stacks == !isPad)
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
        #expect(
            AdaptiveLayout.usesReadableContentWidth(
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("two-column layout on regular horizontal size class")
    func twoColumnOnRegular() {
        #expect(AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: .regular))
        #expect(!AdaptiveLayout.usesTwoColumnLayout(horizontalSizeClass: .compact))
        #expect(AdaptiveLayout.usesTwoColumnPlayerGrid(horizontalSizeClass: .regular))
        #expect(!AdaptiveLayout.usesTwoColumnPlayerGrid(horizontalSizeClass: .compact))
        #expect(
            AdaptiveLayout.usesTwoColumnLayout(
                horizontalSizeClass: .regular,
                verticalSizeClass: .regular
            )
        )
    }

    @Test("iPhone landscape uses phone layout, not iPad two-column")
    func iPhoneLandscapeUsesPhoneLayout() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let usesWideLayout = AdaptiveLayout.usesTwoColumnLayout(
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        )
        #expect(usesWideLayout == isPad)
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

    @Test("uses menu section picker in landscape at default text")
    func menuSectionPickerInLandscape() {
        #expect(
            AdaptiveLayout.usesMenuSectionPicker(
                dynamicType: .large,
                verticalSizeClass: .compact
            )
        )
    }

    @Test("stacks pods action bar for accessibility text sizes and iPhone landscape")
    func stackedPodsActionBarForAccessibility() {
        #expect(AdaptiveLayout.usesStackedPodsActionBar(dynamicType: .accessibility1))
        #expect(!AdaptiveLayout.usesStackedPodsActionBar(dynamicType: .large))

        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let stacksInLandscape = AdaptiveLayout.usesStackedPodsActionBar(
            dynamicType: .large,
            verticalSizeClass: .compact,
            horizontalSizeClass: .regular
        )
        #expect(stacksInLandscape == !isPad)
    }

    @Test("iPad landscape uses compact vertical chrome")
    func iPadLandscapeCompactChrome() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let usesChrome = AdaptiveLayout.usesCompactVerticalChrome(
            horizontalSizeClass: .regular,
            verticalSizeClass: .compact
        )
        #expect(usesChrome == isPad)

        if isPad {
            #expect(
                AdaptiveLayout.chromeVerticalPadding(
                    horizontalSizeClass: .regular,
                    verticalSizeClass: .compact
                ) == 4
            )
        }
    }

    @Test("iPad landscape keeps segmented menu pickers at default text")
    func iPadLandscapeSegmentedPickers() {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let usesMenu = AdaptiveLayout.usesMenuPickerStyle(
            dynamicType: .large,
            verticalSizeClass: .compact,
            horizontalSizeClass: .regular
        )
        #expect(usesMenu == !isPad)
    }

    @Test("does not use menu picker in portrait at default text size")
    func portraitDefaultUsesSegmentedStyle() {
        #expect(
            !AdaptiveLayout.usesMenuPickerStyle(
                dynamicType: .large,
                verticalSizeClass: .regular,
                horizontalSizeClass: .compact
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
