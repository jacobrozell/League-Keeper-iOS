import SwiftUI

/// Shared create/edit form for achievements.
struct AchievementFormView: View {
    @Bindable var viewModel: AchievementFormViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Preview") {
                    AchievementPreviewCard(
                        name: viewModel.name,
                        achievementDescription: viewModel.achievementDescription,
                        points: viewModel.points,
                        alwaysOn: viewModel.alwaysOn,
                        category: viewModel.category,
                        iconName: viewModel.iconName,
                        exclusivity: viewModel.exclusivity
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                if viewModel.isEditMode {
                    Section {
                        Text("Changes apply to future scoring. Past results are unchanged.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Details") {
                    TextField("e.g., First Blood", text: $viewModel.name)
                        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                        .accessibilityLabel("Achievement Name")
                        .accessibilityIdentifier("Achievement Name")

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("What counts for this achievement?", text: $viewModel.achievementDescription, axis: .vertical)
                            .lineLimit(2...4)
                            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                            .accessibilityLabel("Achievement description")

                        Text("\(viewModel.descriptionCharacterCount)/\(AppConstants.Achievement.descriptionMaxLength)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Value") {
                    AchievementPointsTierPicker(
                        points: $viewModel.points,
                        usesCustomPoints: $viewModel.usesCustomPoints
                    )
                }

                Section {
                    Picker("When active", selection: $viewModel.alwaysOn) {
                        Text("Random pool").tag(false)
                        Text("Every week").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Availability")
                } header: {
                    Text("Availability")
                } footer: {
                    Text(viewModel.alwaysOn
                         ? "Included in every week's active achievements."
                         : "Rolled randomly based on tournament settings.")
                }

                Section {
                    Picker("Who can earn", selection: $viewModel.exclusivity) {
                        ForEach(AchievementExclusivity.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .accessibilityLabel("Exclusivity")
                } header: {
                    Text("Exclusivity")
                } footer: {
                    Text(viewModel.exclusivity.footnote)
                }

                Section("Category") {
                    Picker("Category", selection: Binding(
                        get: { viewModel.category },
                        set: { viewModel.selectCategory($0) }
                    )) {
                        ForEach(AchievementCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }

                Section("Icon") {
                    AchievementIconPicker(selectedIconName: $viewModel.iconName) { iconName in
                        viewModel.selectIcon(iconName)
                    }
                }

                Section {
                    PrimaryActionButton(title: viewModel.primaryActionTitle) {
                        viewModel.save()
                    }
                    .disabled(!viewModel.canSave)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } footer: {
                    if !viewModel.canSave {
                        Text("Enter a name for the achievement.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollDismissesKeyboard(.interactively)
            .adaptiveContentWidth()
            .navigationTitle(viewModel.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancel()
                    }
                    .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                }
            }
            .alert("Couldn't Save", isPresented: Binding(
                get: { viewModel.persistenceErrorMessage != nil },
                set: { if !$0 { viewModel.clearPersistenceError() } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.clearPersistenceError()
                }
            } message: {
                Text(viewModel.persistenceErrorMessage ?? PersistenceError.saveFailed.toastMessage)
            }
        }
    }
}

#Preview {
    AchievementFormView(
        viewModel: AchievementFormViewModel(
            context: PreviewContainer.shared.mainContext,
            mode: .add(template: AchievementTemplates.catalog.first)
        )
    )
}
