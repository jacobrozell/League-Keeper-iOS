import Foundation

/// User-facing app identity.
enum AppInfo {
    static let displayName = "League Keeper"
    static let tagline = "Track · Score · Compete"
    static let subtitle = "Your league campaign HQ"

    static let supportURL = URL(string: "https://jacobrozell.github.io/League-Keeper-iOS/support.html")!
    static let privacyURL = URL(string: "https://jacobrozell.github.io/League-Keeper-iOS/privacy.html")!
    static let buyMeACoffeeURL = URL(string: "https://buymeacoffee.com/jacobrozelq")!

    static var isUITesting: Bool {
        let args = ProcessInfo.processInfo.arguments
        return args.contains("--uitesting")
            || args.contains("UI-Testing")
            || args.contains("UI-Testing-Accessibility")
    }
}
