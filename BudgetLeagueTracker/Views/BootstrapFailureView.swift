import SwiftUI

/// Full-screen error when the app cannot open its local data store.
struct BootstrapFailureView: View {
    let onRetry: () -> Void
    let exportURL: URL?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "externaldrive.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Couldn't open league data")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("Your league data may be damaged or unavailable. Try again, export a backup if you can, or contact support.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                PrimaryActionButton(title: "Try Again", action: onRetry)
                    .accessibilityIdentifier("bootstrap_retry")

                if let exportURL {
                    ShareLink(
                        item: exportURL,
                        subject: Text("\(AppInfo.displayName) backup"),
                        message: Text("League Keeper backup file")
                    ) {
                        Label("Export backup if possible", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("bootstrap_export")
                }

                Link(destination: AppInfo.supportURL) {
                    Label("Contact support", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("bootstrap_support")
            }
        }
        .padding(24)
        .adaptiveContentWidth()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
