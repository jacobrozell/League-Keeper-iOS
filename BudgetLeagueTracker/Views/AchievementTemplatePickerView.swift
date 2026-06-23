import SwiftUI

/// Entry point for adding an achievement from a template or blank.
struct AchievementTemplatePickerView: View {
    let onSelectTemplate: (AchievementTemplate?) -> Void
    let onCancel: () -> Void
    var initialLibrary: AchievementTemplateLibrary = .generic

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedLibrary: AchievementTemplateLibrary

    init(
        onSelectTemplate: @escaping (AchievementTemplate?) -> Void,
        onCancel: @escaping () -> Void,
        initialLibrary: AchievementTemplateLibrary = .generic
    ) {
        self.onSelectTemplate = onSelectTemplate
        self.onCancel = onCancel
        self.initialLibrary = initialLibrary
        _selectedLibrary = State(initialValue: initialLibrary)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        onSelectTemplate(nil)
                    } label: {
                        Label("Blank custom achievement", systemImage: "square.and.pencil")
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                    }
                    .accessibilityIdentifier("Blank custom achievement")
                }

                Section {
                    templateLibraryPicker
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Templates") {
                    ForEach(AchievementTemplates.templates(for: selectedLibrary)) { template in
                        Button {
                            onSelectTemplate(template)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: template.iconName)
                                    .foregroundStyle(Color("BrandGold"))
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    AchievementDescriptionText(description: template.achievementDescription, style: .compact)
                                }

                                Spacer()

                                Text("+\(template.points)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                        }
                        .accessibilityLabel("\(template.name), \(template.points) points")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .adaptiveContentWidth()
            .navigationTitle("Add Achievement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    @ViewBuilder
    private var templateLibraryPicker: some View {
        let picker = Picker("Template library", selection: $selectedLibrary) {
            ForEach(AchievementTemplateLibrary.allCases) { library in
                Text(library.displayName).tag(library)
            }
        }

        if AdaptiveLayout.usesMenuPickerStyle(
            dynamicType: dynamicTypeSize,
            verticalSizeClass: verticalSizeClass,
            horizontalSizeClass: horizontalSizeClass
        ) {
            picker.pickerStyle(.menu)
        } else {
            picker.pickerStyle(.segmented)
        }
    }
}

#Preview {
    AchievementTemplatePickerView(onSelectTemplate: { _ in }, onCancel: {})
}
