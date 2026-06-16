import SwiftUI

/// A secondary action button with iOS HIG-compliant styling.
/// Uses `.bordered` style with 44pt minimum touch target.
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var accessibilityLabel: String?
    var accessibilityIdentifier: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let button = Button(action: action) {
            Text(title)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        }
        .buttonStyle(.bordered)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel ?? title)

        if let accessibilityIdentifier {
            button.accessibilityIdentifier(accessibilityIdentifier)
        } else {
            button
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton(title: "Cancel") {}
        
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
