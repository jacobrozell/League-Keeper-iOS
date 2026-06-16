import Foundation
import Testing

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

    @Test("White on system blue (prominent button) meets AA")
    func whiteOnSystemBlue() {
        let ratio = WCAGContrastMath.contrastRatio(
            foreground: Self.white,
            background: Self.systemBlue
        )
        #expect(ratio >= 4.5)
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
