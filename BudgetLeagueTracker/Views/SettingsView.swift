import SwiftUI

/// Settings view — theme, app credit, version, and build info.
struct SettingsView: View {
    @AppStorage("themePreference") private var themeRaw = ThemePreference.system.rawValue
    @Environment(\.palette) private var palette

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var appDisplayName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? AppInfo.displayName
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    BrandCrest(size: 56)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appDisplayName)
                            .font(.system(.title3, design: .serif).weight(.bold))
                        Text(AppInfo.tagline)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: palette.gold))
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
            }

            Section {
                Picker("Theme", selection: Binding(
                    get: { ThemePreference(rawValue: themeRaw) ?? .system },
                    set: { themeRaw = $0.rawValue }
                )) {
                    ForEach(ThemePreference.allCases, id: \.self) { preference in
                        Text(preference.label).tag(preference)
                    }
                }
                .accessibilityIdentifier("settingsThemePicker")
            } header: {
                Text("Appearance")
            }

            Section {
                HStack {
                    Text("Made by \(AppConstants.AppInfo.authorName)")
                        .foregroundStyle(.secondary)
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
        .brandedScreenBackground()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
