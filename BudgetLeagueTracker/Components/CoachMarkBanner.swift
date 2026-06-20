import SwiftUI

/// Dismissible tip shown once to guide hosts through a workflow step.
struct CoachMarkBanner: View {
    let title: String
    let message: String
    var dismissTitle: String = "Got it"
    let onDismiss: () -> Void

    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "lightbulb.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(hex: palette.gold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(dismissTitle, action: onDismiss)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.bordered)
                .accessibilityIdentifier("coachMarkDismiss")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
        .accessibilityIdentifier("coachMarkBanner")
        .onAppear {
            AppAccessibility.announce("\(title). \(message)")
        }
    }
}

#Preview {
    List {
        Section {
            CoachMarkBanner(
                title: "Start each week here",
                message: "Mark who's here, then tap Confirm Attendance to unlock round scoring.",
                onDismiss: {}
            )
        }
    }
    .listStyle(.insetGrouped)
}
