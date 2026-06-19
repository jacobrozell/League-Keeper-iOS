import SwiftUI
import SwiftData
import UniformTypeIdentifiers

/// Settings view — theme, backup, app credit, version, and build info.
struct SettingsView: View {
    var onViewOnboarding: (() -> Void)?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("themePreference") private var themeRaw = ThemePreference.system.rawValue
    @Environment(\.palette) private var palette

    @State private var exportURL: URL?
    @State private var templateURL: URL?
    @State private var showImportPicker = false
    @State private var showImportSheet = false
    @State private var pendingImportData: Data?
    @State private var pendingImportPreview: LeagueBackupImportPreview?
    @State private var backupError: String?
    @State private var backupSuccessMessage: String?
    @State private var dataHealthIssues: [DataHealthChecker.Issue] = []
    @State private var showDataHealthDetail = false

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
                if dataHealthIssues.isEmpty {
                    Label("All league data looks healthy", systemImage: "checkmark.seal")
                        .foregroundStyle(AppConstants.AccessibleColors.activeStatus)
                        .brandedInsetListRow()
                } else {
                    Button {
                        showDataHealthDetail = true
                    } label: {
                        Label("\(dataHealthIssues.count) data issue\(dataHealthIssues.count == 1 ? "" : "s") found", systemImage: "exclamationmark.triangle")
                    }
                    .accessibilityIdentifier("settings_dataHealth")
                    .brandedInsetListRow()
                }
            } header: {
                Text("Data health")
            } footer: {
                if dataHealthIssues.isEmpty {
                    Text("Checks stored tournament data for problems. Export a backup before major changes.")
                        .font(.caption)
                }
            }

            Section {
                if let templateURL {
                    ShareLink(
                        item: templateURL,
                        subject: Text("\(AppInfo.displayName) import template"),
                        message: Text("Fill in player and league details, then import in Settings.")
                    ) {
                        Label("Download import template", systemImage: "doc.badge.arrow.down")
                    }
                    .accessibilityIdentifier("settings_downloadTemplate")
                    .brandedInsetListRow()
                } else {
                    Button {
                        prepareTemplate()
                    } label: {
                        Label("Download import template", systemImage: "doc.badge.arrow.down")
                    }
                    .accessibilityIdentifier("settings_downloadTemplate")
                    .brandedInsetListRow()
                }

                if let exportURL {
                    ShareLink(
                        item: exportURL,
                        subject: Text("\(AppInfo.displayName) backup"),
                        message: Text("League Keeper backup file")
                    ) {
                        Label("Export league data", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("settings_exportBackup")
                    .brandedInsetListRow()
                } else {
                    Button {
                        prepareExport()
                    } label: {
                        Label("Export league data", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("settings_exportBackup")
                    .brandedInsetListRow()
                }

                Button {
                    showImportPicker = true
                } label: {
                    Label("Import league data", systemImage: "square.and.arrow.down")
                }
                .accessibilityIdentifier("settings_importBackup")
                .brandedInsetListRow()
            } header: {
                Text("Data")
            } footer: {
                Text("Download the template to set up players and a league on your computer, then import. Export saves a full backup; import replaces all data on this device.")
                    .font(.caption)
            }

            Section {
                HStack {
                    Text("Made by \(AppConstants.AppInfo.authorName)")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .brandedInsetListRow()
            }

            helpSection

            Section {
                LabeledContent("App", value: appDisplayName)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("App, \(appDisplayName)")
                    .brandedInsetListRow()
                LabeledContent("Version", value: appVersion)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Version, \(appVersion)")
                    .brandedInsetListRow()
                LabeledContent("Build", value: buildNumber)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Build, \(buildNumber)")
                    .brandedInsetListRow()
            } header: {
                Text("About")
            }
        }
        .brandedListChrome()
        .navigationTitle("Settings")
        .adaptiveContentWidth()
        .onAppear {
            prepareTemplate()
            if exportURL == nil {
                prepareExport()
            }
            refreshDataHealth()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                refreshDataHealth()
            }
        }
        .sheet(isPresented: $showDataHealthDetail) {
            dataHealthSheet
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImportSelection(result)
        }
        .sheet(isPresented: $showImportSheet) {
            importConfirmationSheet
        }
        .alert("Backup", isPresented: Binding(
            get: { backupError != nil },
            set: { if !$0 { backupError = nil } }
        )) {
            Button("OK", role: .cancel) { backupError = nil }
        } message: {
            if let backupError {
                Text(backupError)
            }
        }
        .alert("Import complete", isPresented: Binding(
            get: { backupSuccessMessage != nil },
            set: { if !$0 { backupSuccessMessage = nil } }
        )) {
            Button("OK", role: .cancel) { backupSuccessMessage = nil }
        } message: {
            if let backupSuccessMessage {
                Text(backupSuccessMessage)
            }
        }
    }

    @ViewBuilder
    private var helpSection: some View {
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
    }

    @ViewBuilder
    private var dataHealthSheet: some View {
        NavigationStack {
            List {
                Section {
                    Text("Export a backup first if you plan to edit tournaments or import new data.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ForEach(dataHealthIssues) { issue in
                    Section {
                        Text(issue.message)
                        Text(issue.repairHint)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Data health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showDataHealthDetail = false }
                }
            }
        }
    }

    private func refreshDataHealth() {
        dataHealthIssues = DataHealthChecker.scan(context: modelContext)
    }

    @ViewBuilder
    private var importConfirmationSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if let pendingImportPreview {
                    Text(pendingImportPreview.confirmationMessage)
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("This replaces all leagues on this device.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    if let exportURL {
                        ShareLink(
                            item: exportURL,
                            subject: Text("\(AppInfo.displayName) backup"),
                            message: Text("League Keeper backup file")
                        ) {
                            Label("Export backup first", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            prepareExport()
                        } label: {
                            Label("Export backup first", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Import and replace", role: .destructive) {
                        showImportSheet = false
                        confirmImport()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                    .accessibilityIdentifier("settings_confirmImport")
                }

                Spacer(minLength: 0)
            }
            .padding(24)
            .adaptiveContentWidth()
            .navigationTitle("Replace all league data?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        pendingImportData = nil
                        pendingImportPreview = nil
                        showImportSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func prepareExport() {
        do {
            exportURL = try LeagueBackupService.exportURL(context: modelContext)
        } catch {
            backupError = error.localizedDescription
        }
    }

    private func prepareTemplate() {
        do {
            templateURL = try LeagueBackupService.templateURL()
        } catch {
            backupError = error.localizedDescription
        }
    }

    private func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            backupError = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                backupError = LeagueBackupError.importFailed("Could not read the selected file.").localizedDescription
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                pendingImportData = data
                pendingImportPreview = LeagueBackupService.previewImport(data)
                showImportSheet = true
            } catch {
                backupError = error.localizedDescription
            }
        }
    }

    private func confirmImport() {
        guard let pendingImportData else { return }
        do {
            try LeagueBackupService.importBackup(pendingImportData, context: modelContext)
            let preview = pendingImportPreview
            self.pendingImportData = nil
            self.pendingImportPreview = nil
            prepareExport()
            refreshDataHealth()
            backupSuccessMessage = preview?.successMessage ?? "League data restored from backup."
            AppHaptics.success()
        } catch {
            backupError = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Player.self, Achievement.self, LeagueState.self, Tournament.self, GameResult.self], inMemory: true)
}
