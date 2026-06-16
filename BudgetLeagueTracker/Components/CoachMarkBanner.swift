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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("coachMarkBanner")
    }
}

#Preview {
    List {
        Section {
            CoachMarkBanner(
                title: "Start each week here",
                message: "Mark who's here, then tap Confirm Attendance to unlock pod scoring.",
                onDismiss: {}
            )
        }
    }
    .listStyle(.insetGrouped)
}
