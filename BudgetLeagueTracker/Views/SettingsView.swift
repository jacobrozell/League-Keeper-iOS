import SwiftUI

/// Settings view - app credit, version, and build info. Expandable for future settings.
struct SettingsView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var appDisplayName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "—"
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Made by \(AppConstants.AppInfo.authorName)")
                        .foregroundStyle(AppConstants.AccessibleColors.secondaryText)
                    Spacer()
                }
            }

            Section {
                LabeledContent("App", value: appDisplayName)
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build", value: buildNumber)
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
