import SwiftUI
import Charts

/// Compact cumulative points sparkline for list rows.
struct PlayerSparklineView: View {
    let points: [Double]
    var height: CGFloat = 24

    var body: some View {
        Group {
            if points.count >= 2 {
                Chart {
                    ForEach(Array(points.enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Game", index),
                            y: .value("Points", value)
                        )
                        .foregroundStyle(AppConstants.AccessibleColors.placementAccent)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                .frame(width: 56, height: height)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(sparklineAccessibilityLabel)
            }
        }
    }

    private var sparklineAccessibilityLabel: String {
        guard let last = points.last else { return "No trend data" }
        return "Points trend, latest cumulative \(Int(last))"
    }
}

#Preview {
    PlayerSparklineView(points: [4, 7, 10, 14, 18, 22])
        .padding()
}
