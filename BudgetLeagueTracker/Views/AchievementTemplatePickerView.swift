import SwiftUI

/// Entry point for adding an achievement from a template or blank.
struct AchievementTemplatePickerView: View {
    let onSelectTemplate: (AchievementTemplate?) -> Void
    let onCancel: () -> Void

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

                Section("Templates") {
                    ForEach(AchievementTemplates.catalog) { template in
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
            .navigationTitle("Add Achievement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

#Preview {
    AchievementTemplatePickerView(onSelectTemplate: { _ in }, onCancel: {})
}
