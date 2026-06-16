import SwiftUI

/// Settings view — theme, app credit, version, and build info.
struct SettingsView: View {
    var onViewOnboarding: (() -> Void)?

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
                    BrandCrest(size: 56, showsShadow: false)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appDisplayName)
                            .font(.system(.title3, design: .serif).weight(.bold))
                            .foregroundStyle(Color(hex: palette.ink))
                        Text(AppInfo.tagline)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: palette.gold))
                    }
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
                .brandedInsetListRow()
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
                .brandedInsetListRow()
            } header: {
                Text("Appearance")
            }

            Section {
                HStack {
                    Text("Made by \(AppConstants.AppInfo.authorName)")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .brandedInsetListRow()
            }

            if let onViewOnboarding {
                Section {
                    Button {
                        onViewOnboarding()
                    } label: {
                        Label("View welcome tour", systemImage: "book.pages")
                    }
                    .accessibilityIdentifier("settings_viewOnboardingButton")
                    .brandedInsetListRow()

                    Link(destination: AppInfo.supportURL) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    .accessibilityIdentifier("settings_supportLink")
                    .brandedInsetListRow()

                    Link(destination: AppInfo.privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    .accessibilityIdentifier("settings_privacyLink")
                    .brandedInsetListRow()

                    Link(destination: AppInfo.buyMeACoffeeURL) {
                        Label("Buy Me a Coffee", systemImage: "cup.and.saucer.fill")
                    }
                    .accessibilityIdentifier("settings_buyMeACoffeeLink")
                    .brandedInsetListRow()
                } header: {
                    Text("Help")
                }
            } else {
                Section {
                    Link(destination: AppInfo.supportURL) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    .accessibilityIdentifier("settings_supportLink")
                    .brandedInsetListRow()

                    Link(destination: AppInfo.privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    .accessibilityIdentifier("settings_privacyLink")
                    .brandedInsetListRow()

                    Link(destination: AppInfo.buyMeACoffeeURL) {
                        Label("Buy Me a Coffee", systemImage: "cup.and.saucer.fill")
                    }
                    .accessibilityIdentifier("settings_buyMeACoffeeLink")
                    .brandedInsetListRow()
                } header: {
                    Text("Help")
                }
            }

            Section {
                LabeledContent("App", value: appDisplayName)
                    .brandedInsetListRow()
                LabeledContent("Version", value: appVersion)
                    .brandedInsetListRow()
                LabeledContent("Build", value: buildNumber)
                    .brandedInsetListRow()
            } header: {
                Text("About")
            }
        }
        .brandedListChrome()
        .navigationTitle("Settings")
        .adaptiveContentWidth()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
