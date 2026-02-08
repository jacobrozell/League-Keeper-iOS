import Testing
import SwiftUI
import SnapshotTesting
@testable import BudgetLeagueTracker

/// Snapshot tests for chart components (BarChartView, LineChartView, PieChartView, AchievementStatsCard).
/// Note: Set `SnapshotTestConfiguration.record = true` to generate reference snapshots.
@Suite("Charts Snapshot Tests")
@MainActor
struct ChartsSnapshotTests {

    @Suite("BarChartView")
    @MainActor
    struct BarChartViewSnapshots {
        @Test("Empty data")
        func emptyData() {
            let view = BarChartView(title: "Points", data: [], height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }

        @Test("Single series")
        func singleSeries() {
            let data = [
                BarChartData(label: "Alice", value: 12),
                BarChartData(label: "Bob", value: 8),
                BarChartData(label: "Charlie", value: 15)
            ]
            let view = BarChartView(title: "Scores", data: data, height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }

        @Test("Single series (dark mode)")
        func singleSeriesDark() {
            let data = [
                BarChartData(label: "Alice", value: 12),
                BarChartData(label: "Bob", value: 8),
                BarChartData(label: "Charlie", value: 15)
            ]
            let view = BarChartView(title: "Scores", data: data, height: 200)
                .frame(width: 350, height: 240)
                .darkModeForSnapshot()
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), named: "singleSeries_dark", record: SnapshotTestConfiguration.record)
        }

        @Test("Grouped bars")
        func groupedBars() {
            let data = [
                BarChartData(label: "Alice", primaryValue: 20, primaryLabel: "Placement", secondaryValue: 8, secondaryLabel: "Achievement"),
                BarChartData(label: "Bob", primaryValue: 15, primaryLabel: "Placement", secondaryValue: 10, secondaryLabel: "Achievement")
            ]
            let view = BarChartView(title: "Points", data: data, barColor: Color(uiColor: .systemBlue), secondaryColor: Color(uiColor: .systemGreen), height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }
    }

    @Suite("LineChartView")
    @MainActor
    struct LineChartViewSnapshots {
        @Test("Empty data")
        func emptyData() {
            let view = LineChartView(title: "Trend", data: [], height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }

        @Test("Single series")
        func singleSeries() {
            let data = [
                LineChartData(xValue: 1, yValue: 10),
                LineChartData(xValue: 2, yValue: 25),
                LineChartData(xValue: 3, yValue: 40)
            ]
            let view = LineChartView(title: "Progress", data: data, height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }
    }

    @Suite("PieChartView")
    @MainActor
    struct PieChartViewSnapshots {
        @Test("Empty data")
        func emptyData() {
            let view = PieChartView(title: "Distribution", data: [], height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }

        @Test("With segments")
        func withSegments() {
            let data = [
                PieChartData(label: "1st", value: 5, color: Color(uiColor: .systemYellow)),
                PieChartData(label: "2nd", value: 8, color: Color(uiColor: .systemGray)),
                PieChartData(label: "3rd", value: 6, color: Color(uiColor: .systemOrange)),
                PieChartData(label: "4th", value: 3, color: Color(uiColor: .systemBrown))
            ]
            let view = PieChartView(title: "Placements", data: data, height: 200)
                .frame(width: 350, height: 240)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }
    }

    @Suite("AchievementStatsCard")
    @MainActor
    struct AchievementStatsCardSnapshots {
        @Test("With top earners")
        func withTopEarners() {
            let card = AchievementStatsCard(
                achievementName: "First Blood",
                achievementPoints: 1,
                totalEarned: 12,
                topEarners: [("Alice", 5), ("Bob", 4), ("Charlie", 3)],
                isAlwaysOn: true,
                showDetailedBreakdown: true,
                onToggleAlwaysOn: nil,
                onRemove: nil
            )
            let view = card.frame(width: 350)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }

        @Test("Minimal")
        func minimal() {
            let card = AchievementStatsCard(
                achievementName: "Rare Win",
                achievementPoints: 3,
                totalEarned: 0,
                topEarners: [],
                isAlwaysOn: false,
                showDetailedBreakdown: false,
                onToggleAlwaysOn: nil,
                onRemove: nil
            )
            let view = card.frame(width: 350)
            assertSnapshot(of: view, as: .image(precision: 0.98, layout: .fixed(width: 350, height: 240)), record: SnapshotTestConfiguration.record)
        }
    }
}
