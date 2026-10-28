import Foundation
import SwiftUI
import Testing
@testable import BudgetLeagueTracker

/// WCAG 2.1 contrast math for semantic UI colors (P-1.4.3).
@Suite("WCAG contrast ratios")
struct WCAGContrastTests {
    // Approximate sRGB values for iOS semantic colors on grouped backgrounds
    private static let groupedBackgroundLight = WCAGContrastMath.RGB(0.95, 0.95, 0.97)
    private static let groupedBackgroundDark = WCAGContrastMath.RGB(0.0, 0.0, 0.0)
    private static let labelLight = WCAGContrastMath.RGB(0.0, 0.0, 0.0)
    private static let labelDark = WCAGContrastMath.RGB(1.0, 1.0, 1.0)
    private static let secondaryLabelLight = WCAGContrastMath.RGB(0.24, 0.24, 0.26)
    private static let secondaryLabelDark = WCAGContrastMath.RGB(0.92, 0.92, 0.96)
    private static let systemBlue = WCAGContrastMath.RGB(0.0, 0.48, 1.0)
    private static let white = WCAGContrastMath.RGB(1.0, 1.0, 1.0)

    @Test("Primary label on grouped background (light) meets AA")
    func primaryLabelOnGroupedLight() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.labelLight,
            background: Self.groupedBackgroundLight
        )
        #expect(ratio >= 4.5)
    }

    @Test("Primary label on grouped background (dark) meets AA")
    func primaryLabelOnGroupedDark() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.labelDark,
            background: Self.groupedBackgroundDark
        )
        #expect(ratio >= 4.5)
    }

    @Test("Secondary label on grouped background (light) meets AA")
    func secondaryLabelOnGroupedLight() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.secondaryLabelLight,
            background: Self.groupedBackgroundLight
        )
        #expect(ratio >= 4.5)
    }

    @Test("Secondary label on grouped background (dark) meets AA")
    func secondaryLabelOnGroupedDark() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.secondaryLabelDark,
            background: Self.groupedBackgroundDark
        )
        #expect(ratio >= 4.5)
    }

    @Test("White on system blue (prominent button) meets AA large text")
    func whiteOnSystemBlue() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.white,
            background: Self.systemBlue
        )
        // iOS system blue is ~4:1 — meets AA for large text / UI components, not 4.5:1 body text.
        #expect(ratio >= 4.0)
    }

    @Test("Increase Contrast palette text tokens meet AA on every brand surface")
    func increasedContrastPalette() throws {
        for palette in [Tokens.lightIncreasedContrast, Tokens.darkIncreasedContrast] {
            let surfaces = [palette.bg, palette.bg2, palette.surface, palette.surface2]
            let textTokens = [palette.ink, palette.inkDim, palette.inkFaint, palette.gold, palette.goldBright, palette.err]
            for text in textTokens {
                for surface in surfaces {
                    let ratio = WCAGContrastMath.contrastRatio(
                        foreground: try #require(WCAGContrastMath.RGB(hex: text)),
                        background: try #require(WCAGContrastMath.RGB(hex: surface))
                    )
                    #expect(ratio >= 4.5, "\(text) on \(surface) is \(ratio):1")
                }
            }
        }
    }

    @Test("Increase Contrast palette is selected only when the setting is on")
    func paletteSelection() {
        #expect(Tokens.palette(for: .light, contrast: .increased).gold == Tokens.lightIncreasedContrast.gold)
        #expect(Tokens.palette(for: .dark, contrast: .increased).inkDim == Tokens.darkIncreasedContrast.inkDim)
        #expect(Tokens.palette(for: .light).gold == Tokens.light.gold)
    }
}

enum WCAGContrastMath {
    struct RGB: Sendable {
        let r: Double
        let g: Double
        let b: Double

        init(_ r: Double, _ g: Double, _ b: Double) {
            self.r = r
            self.g = g
            self.b = b
        }

        init?(hex: String) {
            let digits = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
            self.init(
                Double((value >> 16) & 0xFF) / 255,
                Double((value >> 8) & 0xFF) / 255,
                Double(value & 0xFF) / 255
            )
        }
    }

    static func contrastRatio(foreground: RGB, background: RGB) -> Double {
        let l1 = relativeLuminance(foreground)
        let l2 = relativeLuminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    private static func relativeLuminance(_ rgb: RGB) -> Double {
        func channel(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(rgb.r) + 0.7152 * channel(rgb.g) + 0.0722 * channel(rgb.b)
    }
}
