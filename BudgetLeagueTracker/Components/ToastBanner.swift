import SwiftUI

/// Brief transient status message shown at the top of a screen.
struct ToastBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)
            .accessibilityAddTraits(.isStaticText)
            .accessibilityLabel(message)
            .onAppear {
                AppAccessibility.announce(message)
            }
    }
}

#Preview {
    ToastBanner(message: "Round 1 saved")
        .padding(.top)
}
