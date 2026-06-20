import SwiftUI

/// A segmented picker for selecting placement (1st through 4th).
/// Ensures accessibility and disabled state support.
struct PlacementPicker: View {
    let playerName: String
    @Binding var selection: Int
    var maxPlace: Int = AppConstants.League.podSize
    var isDisabled: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        Group {
            if AdaptiveLayout.usesMenuPickerStyle(
                dynamicType: dynamicTypeSize,
                verticalSizeClass: verticalSizeClass,
                horizontalSizeClass: horizontalSizeClass
            ) {
                placementPicker
                    .pickerStyle(.menu)
            } else {
                placementPicker
                    .pickerStyle(.segmented)
            }
        }
        .disabled(isDisabled)
        .accessibilityIdentifier("placement-\(playerName)")
        .accessibilityLabel("Placement for \(playerName)")
        .accessibilityValue(placementLabel)
        .accessibilityHint(isDisabled ? "Placement locked" : "Select finishing place for \(playerName)")
    }

    private var placementPicker: some View {
        let upperBound = max(maxPlace, 1)
        return Picker("Placement", selection: $selection) {
            ForEach(1...upperBound, id: \.self) { place in
                Text(Self.shortLabel(for: place))
                    .tag(place)
            }
        }
    }
    
    private var placementLabel: String {
        switch selection {
        case 1: return "First place"
        case 2: return "Second place"
        case 3: return "Third place"
        case 4: return "Fourth place"
        default: return "\(selection)"
        }
    }

    static func shortLabel(for place: Int) -> String {
        switch place {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        case 4: return "4th"
        default: return "\(place)"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PlacementPicker(playerName: "Alice", selection: .constant(1))
        PlacementPicker(playerName: "Bob", selection: .constant(2), isDisabled: true)
    }
    .padding()
}
