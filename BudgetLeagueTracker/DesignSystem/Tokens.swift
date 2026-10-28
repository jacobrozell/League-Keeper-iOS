import SwiftUI

/// Colour tokens aligned with MiniMuster — warm parchment / gold brand palette.
enum Tokens {
    struct Palette {
        let bg, bg2, surface, surface2, line, ink, inkDim, inkFaint: String
        let gold, goldBright, blood, crestText, chipOnText, err: String
    }

    static let dark = Palette(
        bg: "#0b0c0f", bg2: "#101218", surface: "#15171e", surface2: "#1b1e27",
        line: "#2a2d38", ink: "#e8e5dc", inkDim: "#9a978c", inkFaint: "#65636b",
        gold: "#c9a44c", goldBright: "#e6c878", blood: "#8c2b22",
        crestText: "#0b0c0f", chipOnText: "#1a1407", err: "#f87171")

    static let light = Palette(
        bg: "#f4f1ea", bg2: "#ebe6dc", surface: "#fffdf8", surface2: "#f0ebe3",
        line: "#d4cfc4", ink: "#1a1814", inkDim: "#5c574e", inkFaint: "#8a8478",
        gold: "#9a7428", goldBright: "#7a5a18", blood: "#a83228",
        crestText: "#fffdf8", chipOnText: "#fffdf8", err: "#dc2626")

    /// Light palette for Increase Contrast — gold and dim ink darkened to 4.5:1 on every light surface.
    static let lightIncreasedContrast = Palette(
        bg: light.bg, bg2: light.bg2, surface: light.surface, surface2: light.surface2,
        line: "#a8a296", ink: light.ink, inkDim: "#4a463e", inkFaint: "#5c574e",
        gold: "#7a5a18", goldBright: "#5e4410", blood: light.blood,
        crestText: light.crestText, chipOnText: light.chipOnText, err: "#b91c1c")

    /// Dark palette for Increase Contrast — dim and faint ink lifted above 4.5:1.
    static let darkIncreasedContrast = Palette(
        bg: dark.bg, bg2: dark.bg2, surface: dark.surface, surface2: dark.surface2,
        line: "#4a4e5c", ink: dark.ink, inkDim: "#b8b5aa", inkFaint: "#9a978c",
        gold: dark.gold, goldBright: dark.goldBright, blood: dark.blood,
        crestText: dark.crestText, chipOnText: dark.chipOnText, err: dark.err)

    static func palette(for scheme: ColorScheme, contrast: ColorSchemeContrast = .standard) -> Palette {
        switch (scheme, contrast) {
        case (.dark, .increased): darkIncreasedContrast
        case (.dark, _): dark
        case (_, .increased): lightIncreasedContrast
        default: light
        }
    }
}

extension EnvironmentValues {
    /// Active brand palette for the current colour scheme and contrast setting.
    var palette: Tokens.Palette {
        Tokens.palette(for: colorScheme, contrast: colorSchemeContrast)
    }
}
