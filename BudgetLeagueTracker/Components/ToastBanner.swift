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

// MARK: - Toast presentation

enum ToastPresentation {
    static let defaultDuration: Duration = .seconds(2.5)

    @MainActor
    static func show(_ message: String, binding: Binding<String?>) {
        binding.wrappedValue = message
        let shown = message
        Task {
            try? await Task.sleep(for: defaultDuration)
            if binding.wrappedValue == shown {
                binding.wrappedValue = nil
            }
        }
    }
}

private struct ToastOverlayModifier: ViewModifier {
    let message: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let message {
                    ToastBanner(message: message)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: message != nil)
    }
}

extension View {
    func toastOverlay(_ message: String?) -> some View {
        modifier(ToastOverlayModifier(message: message))
    }

    func onPersistenceError(
        _ message: String?,
        showToast: @escaping (String) -> Void,
        clearError: @escaping () -> Void
    ) -> some View {
        onChange(of: message) { _, newMessage in
            if let newMessage {
                showToast(newMessage)
                clearError()
            }
        }
    }
}

#Preview {
    ToastBanner(message: "Round 1 saved")
        .padding(.top)
}
