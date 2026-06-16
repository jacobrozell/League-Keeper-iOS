import SwiftUI

/// Theme preference: dark, light, or follow the system. Matches MiniMuster settings UX.
enum ThemePreference: String, CaseIterable, Sendable {
    case dark, light, system

    var label: String { rawValue.capitalized }

    /// SwiftUI colour-scheme override. `system` → nil (follow the device).
    var colorScheme: ColorScheme? {
        switch self {
        case .dark: .dark
        case .light: .light
        case .system: nil
        }
    }

    /// Launch-argument override for UI tests and screenshots.
    static func resolved(
        storedRaw: String,
        launchArguments: [String] = ProcessInfo.processInfo.arguments
    ) -> ThemePreference {
        if launchArguments.contains("UI-Testing-DarkTheme") { return .dark }
        if launchArguments.contains("UI-Testing-LightTheme") { return .light }
        return ThemePreference(rawValue: storedRaw) ?? .system
    }
}
