import SwiftUI

/// Shared state for a step in the tournament week progress strip.
enum TournamentProgressStepState {
    case complete
    case current
    case upcoming
}

/// A single step in the host progress indicator.
struct TournamentProgressStep: Identifiable {
    let id: String
    let title: String
    let state: TournamentProgressStepState
}

/// Shows week/round context and where the host is in the weekly flow.
struct TournamentProgressHeader: View {
    let weekLabel: String
    let roundLabel: String
    let steps: [TournamentProgressStep]
    let currentRound: Int
    let roundsPerWeek: Int
    let nextStepHint: String
    var presetLabel: String? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.palette) private var palette
    @State private var showsProgressDetails = false

    /// Compact header whenever vertical space is limited (iPhone landscape, iPad landscape).
    private var usesLandscapeChrome: Bool {
        verticalSizeClass == .compact
    }

    var body: some View {
        VStack(alignment: .leading, spacing: usesLandscapeChrome ? 6 : 10) {
            if dynamicTypeSize.isAccessibilitySize {
                accessibilityContextHeader
                if showsProgressDetails {
                    accessibilityStepList
                    Button("Hide progress steps") {
                        showsProgressDetails = false
                    }
                    .font(.caption.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("progressStepsToggle")
                } else {
                    Button("Show progress steps") {
                        showsProgressDetails = true
                    }
                    .font(.caption.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("progressStepsToggle")
                }
            } else {
                HStack {
                    Text(weekLabel)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(roundLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                compactStepStrip
            }

            Text(nextStepHint)
                .font(usesLandscapeChrome ? .caption2 : .caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(usesLandscapeChrome ? 2 : nil)
                .accessibilityLabel("Next step: \(nextStepHint)")

            if let presetLabel {
                Text(presetLabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(hex: palette.gold))
                    .accessibilityLabel("League type: \(presetLabel)")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, usesLandscapeChrome ? 6 : 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
    }

    @ViewBuilder
    private var accessibilityContextHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(weekLabel)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(roundLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var compactStepStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                if index > 0 {
                    stepConnector(isComplete: steps[index - 1].state == .complete)
                }
                stepNode(step, titleFont: .caption2, titleLineLimit: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressAccessibilityLabel)
    }

    @ViewBuilder
    private var accessibilityStepList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(steps) { step in
                HStack(alignment: .top, spacing: 12) {
                    stepIndicatorCircle(for: step.state)
                    Text(step.title)
                        .font(.subheadline)
                        .foregroundStyle(step.state == .upcoming ? Color.secondary : Color.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progressAccessibilityLabel)
    }

    @ViewBuilder
    private func stepNode(
        _ step: TournamentProgressStep,
        titleFont: Font,
        titleLineLimit: Int?
    ) -> some View {
        VStack(spacing: 4) {
            stepIndicatorCircle(for: step.state)
            Text(step.title)
                .font(titleFont)
                .foregroundStyle(step.state == .upcoming ? Color.secondary : Color.primary)
                .lineLimit(titleLineLimit)
                .minimumScaleFactor(titleLineLimit == 1 ? 0.8 : 1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func stepIndicatorCircle(for state: TournamentProgressStepState) -> some View {
        ZStack {
            Circle()
                .fill(stepFill(for: state))
                .frame(width: 22, height: 22)
            if state == .complete {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color(hex: palette.chipOnText))
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func stepConnector(isComplete: Bool) -> some View {
        Rectangle()
            .fill(isComplete ? Color(hex: palette.gold) : Color(.separator))
            .frame(height: 2)
            .frame(maxWidth: 24)
            .padding(.bottom, 14)
    }

    private func stepFill(for state: TournamentProgressStepState) -> Color {
        switch state {
        case .complete:
            return Color(hex: palette.gold)
        case .current:
            return Color(hex: palette.gold).opacity(0.25)
        case .upcoming:
            return Color(.tertiarySystemFill)
        }
    }

    private var progressAccessibilityLabel: String {
        let stepDescriptions = steps.map { step -> String in
            switch step.state {
            case .complete: return "\(step.title), complete"
            case .current: return "\(step.title), current"
            case .upcoming: return "\(step.title), upcoming"
            }
        }
        return stepDescriptions.joined(separator: ", ")
    }
}

#Preview {
    TournamentProgressHeader(
        weekLabel: "Week 2 of 6",
        roundLabel: "Round 1 of 3",
        steps: [
            TournamentProgressStep(id: "attendance", title: "Attendance", state: .complete),
            TournamentProgressStep(id: "seat", title: "Seat Players", state: .current),
            TournamentProgressStep(id: "score", title: "Score", state: .upcoming)
        ],
        currentRound: 1,
        roundsPerWeek: 3,
        nextStepHint: "Seat players for Round 1"
    )
}
