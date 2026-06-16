import SwiftUI

/// A prominent primary action button with iOS HIG-compliant styling.
/// Uses `.borderedProminent` style with 44pt minimum touch target.
struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var accessibilityLabel: String?
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("AccentColor"))
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel ?? title)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryActionButton(title: "Start Tournament") {}
        
        PrimaryActionButton(title: "Disabled Button", action: {}, isDisabled: true)
    }
    .padding()
}
