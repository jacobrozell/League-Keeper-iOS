import SwiftUI
import UIKit

/// VoiceOver helpers — announcements and reusable accessibility modifiers.
@MainActor
enum AppAccessibility {
    /// Speaks a short status message (toasts, confirmations). Skipped during UI tests.
    static func announce(_ message: String) {
        guard !message.isEmpty, !AppInfo.isUITesting else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

extension View {
    /// Menu/segment pickers: label + which option is selected.
    func accessibilitySelectedSection(_ title: String, value: String) -> some View {
        accessibilityLabel(title)
            .accessibilityValue("Selected, \(value)")
    }

    @ViewBuilder
    func accessibilityHintIf(_ hint: String?) -> some View {
        if let hint, !hint.isEmpty {
            accessibilityHint(hint)
        } else {
            self
        }
    }

    /// Toolbar buttons: show icon + title at accessibility text sizes.
    @ViewBuilder
    func adaptiveToolbarLabelStyle(isAccessibilitySize: Bool) -> some View {
        if isAccessibilitySize {
            labelStyle(.titleAndIcon)
        } else {
            labelStyle(.iconOnly)
        }
    }
}
