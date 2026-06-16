import SwiftUI

/// Grid picker for achievement SF Symbol icons.
struct AchievementIconPicker: View {
    @Binding var selectedIconName: String
    var onSelect: ((String) -> Void)?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(AchievementCategory.allCases) { category in
                if let icons = AppConstants.Achievement.iconAllowlistByCategory[category], !icons.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.displayName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(icons, id: \.self) { iconName in
                                iconCell(iconName)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func iconCell(_ iconName: String) -> some View {
        let isSelected = selectedIconName == iconName

        Button {
            selectedIconName = iconName
            onSelect?(iconName)
        } label: {
            Image(systemName: iconName)
                .font(.title3)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
                .background(isSelected ? Color("BrandGold").opacity(0.2) : Color(.tertiarySystemBackground))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("BrandGold"), lineWidth: 2)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(AppConstants.Achievement.iconDisplayName(iconName)) icon")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("icon-\(iconName)")
    }
}

#Preview {
    ScrollView {
        AchievementIconPicker(selectedIconName: .constant("flame.fill"))
            .padding()
    }
}
