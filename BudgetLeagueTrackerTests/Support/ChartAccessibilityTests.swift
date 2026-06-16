import SwiftUI
import Testing
@testable import BudgetLeagueTracker

@Suite("ChartAccessibility")
struct ChartAccessibilityTests {
    @Test("bar chart summary lists values")
    func barSummary() {
        let summary = ChartAccessibility.barChartSummary(
            title: "Wins",
            data: [BarChartData(label: "Alex", value: 3)]
        )
        #expect(summary.contains("Wins"))
        #expect(summary.contains("Alex: 3"))
    }

    @Test("pie chart summary includes percentages")
    func pieSummary() {
        let summary = ChartAccessibility.pieChartSummary(
            title: "Distribution",
            data: [
                PieChartData(label: "First Blood", value: 2, color: .orange),
                PieChartData(label: "Combo", value: 2, color: .blue)
            ]
        )
        #expect(summary.contains("50%"))
        #expect(summary.contains("Total 4"))
    }
}
