import SwiftUI

/// A prominent primary action button with iOS HIG-compliant styling.
/// Uses `.borderedProminent` style with 44pt minimum touch target.
struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var accessibilityLabel: String?
    var accessibilityIdentifier: String?
    var disabledAccessibilityHint: String?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let button = Button(action: action) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("AccentColor"))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.55 : 1)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityHintIf(isDisabled ? disabledAccessibilityHint : nil)

        if let accessibilityIdentifier {
            button.accessibilityIdentifier(accessibilityIdentifier)
        } else {
            button
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryActionButton(title: "Start Tournament") {}
        
        PrimaryActionButton(title: "Disabled Button", action: {}, isDisabled: true)
    }
    .padding()
}
