import SwiftUI

/// Brief transient status message shown at the top of a screen.
struct ToastBanner: View {
    let message: String

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var maxBannerWidth: CGFloat {
        AdaptiveLayout.usesReadableContentWidth(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) ? 480 : .infinity
    }

    var body: some View {
        Text(message)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: maxBannerWidth)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            .frame(maxWidth: .infinity)
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
