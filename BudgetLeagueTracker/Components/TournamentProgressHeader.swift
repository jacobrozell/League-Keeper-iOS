import SwiftUI

/// Visual state for a step in the tournament week progress strip.
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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.palette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weekLabel)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(roundLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
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
            }

            if dynamicTypeSize.isAccessibilitySize {
                accessibilityStepList
            } else {
                compactStepStrip
            }

            roundDots

            Text(nextStepHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("Next step: \(nextStepHint)")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
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
                        .foregroundStyle(step.state == .upcoming ? .tertiary : .primary)
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
                .foregroundStyle(step.state == .upcoming ? .tertiary : .primary)
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

    @ViewBuilder
    private var roundDots: some View {
        HStack(spacing: 6) {
            ForEach(1...roundsPerWeek, id: \.self) { round in
                Circle()
                    .fill(round <= currentRound ? Color(hex: palette.gold) : Color(.tertiarySystemFill))
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
            Text("Round \(currentRound) of \(roundsPerWeek)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Round \(currentRound) of \(roundsPerWeek)")
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
        roundLabel: "Round 1",
        steps: [
            TournamentProgressStep(id: "attendance", title: "Attendance", state: .complete),
            TournamentProgressStep(id: "pods", title: "Pods", state: .current),
            TournamentProgressStep(id: "score", title: "Score", state: .upcoming)
        ],
        currentRound: 1,
        roundsPerWeek: 3,
        nextStepHint: "Generate pods for Round 1"
    )
}
