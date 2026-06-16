import Foundation

public struct FirebaseAnalyticsEvent: Equatable, Sendable {
    public let name: String
    public let parameters: [String: String]
}

public enum FirebaseAnalyticsEventMapping {
    private static let allowlistedLogEvents: Set<String> = [
        "app_bootstrap_ready",
        "tournament_created",
        "tournament_completed",
        "round_recorded",
        "achievement_added",
        "model_container_bootstrap_failure"
    ]

    private static let firebaseNameOverrides: [String: String] = [
        "app_bootstrap_ready": "app_open"
    ]

    public static func map(_ entry: LogEntry, appVersion: String?) -> FirebaseAnalyticsEvent? {
        guard allowlistedLogEvents.contains(entry.eventName) else { return nil }

        var parameters = sanitizedParameters(from: entry.metadata)
        if let appVersion, !appVersion.isEmpty {
            parameters["app_version"] = appVersion
        }
        parameters["log_category"] = entry.category.rawValue

        let firebaseName = firebaseNameOverrides[entry.eventName] ?? entry.eventName
        return FirebaseAnalyticsEvent(name: firebaseName, parameters: parameters)
    }

    private static func sanitizedParameters(from metadata: [String: String]) -> [String: String] {
        metadata.reduce(into: [:]) { result, pair in
            guard AnalyticsMetadataKeys.firebaseParameters.contains(pair.key) else { return }
            let value = String(pair.value.prefix(100))
            guard !value.isEmpty else { return }
            result[pair.key] = value
        }
    }
}
