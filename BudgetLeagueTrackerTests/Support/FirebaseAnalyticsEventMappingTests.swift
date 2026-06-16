import Foundation
import Testing
@testable import BudgetLeagueTracker

@Suite("Firebase Analytics Event Mapping")
struct FirebaseAnalyticsEventMappingTests {
    @Test("Maps app bootstrap to app_open")
    func appBootstrapReady() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .appLifecycle,
            eventName: "app_bootstrap_ready",
            message: "ready",
            metadata: [:],
            correlationId: nil
        )
        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: "1.0.0")
        #expect(event?.name == "app_open")
        #expect(event?.parameters["app_version"] == "1.0.0")
    }

    @Test("Rejects non-allowlisted events")
    func rejectsUnknownEvents() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .ui,
            eventName: "player_name_typed",
            message: "should not ship",
            metadata: ["playerName": "Alice"],
            correlationId: nil
        )
        #expect(FirebaseAnalyticsEventMapping.map(entry, appVersion: nil) == nil)
    }

    @Test("Sanitizes allowlisted metadata only")
    func sanitizesMetadata() {
        let entry = LogEntry(
            timestamp: Date(),
            level: .info,
            category: .scoring,
            eventName: "round_recorded",
            message: "week saved",
            metadata: [
                "weekNumber": "3",
                "playerName": "Alice"
            ],
            correlationId: nil
        )
        let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: nil)
        #expect(event?.parameters["weekNumber"] == "3")
        #expect(event?.parameters["playerName"] == nil)
    }
}
