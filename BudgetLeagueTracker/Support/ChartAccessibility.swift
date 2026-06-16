import Foundation

/// VoiceOver summaries for chart components (LKX-CHART-A11Y).
enum ChartAccessibility {
    static func barChartSummary(title: String, data: [BarChartData]) -> String {
        guard !data.isEmpty else { return "\(title). No data." }
        let items = data.map { item in
            if let secondary = item.secondaryValue, let secondaryLabel = item.secondaryLabel {
                return "\(item.label): \(item.primaryLabel ?? "Primary") \(item.primaryValue), \(secondaryLabel) \(secondary)"
            }
            return "\(item.label): \(item.primaryValue)"
        }
        return "\(title). \(items.joined(separator: "; "))"
    }

    static func lineChartSummary(title: String, data: [LineChartData]) -> String {
        guard !data.isEmpty else { return "\(title). No data." }
        let series = Dictionary(grouping: data, by: \.series)
        let parts = series.map { name, points in
            let sorted = points.sorted { $0.xValue < $1.xValue }
            let trend = sorted.map { "week \($0.xValue) \($0.yValue) points" }.joined(separator: ", ")
            return "\(name): \(trend)"
        }
        return "\(title). \(parts.joined(separator: "; "))"
    }

    static func pieChartSummary(title: String, data: [PieChartData]) -> String {
        let total = data.reduce(0) { $0 + $1.value }
        guard total > 0 else { return "\(title). No data." }
        let items = data.map { item in
            let pct = Int(round(Double(item.value) / Double(total) * 100))
            return "\(item.label) \(item.value) (\(pct)%)"
        }
        return "\(title). Total \(total). \(items.joined(separator: "; "))"
    }
}
