import Foundation

public enum FirebaseCrashlyticsEventMapping {
    private static let errorDomain = "com.budgetleague.BudgetLeagueTracker.logger"

    private static let allowlistedLogEvents: Set<String> = [
        "model_container_bootstrap_failure",
        "tournament_save_failed",
        "round_save_failed"
    ]

    static let eventCodes: [String: Int] = [
        "model_container_bootstrap_failure": 1001,
        "tournament_save_failed": 1002,
        "round_save_failed": 1003
    ]

    public static func nonFatalError(for entry: LogEntry, appVersion: String?) -> NSError? {
        guard entry.level >= .error,
              allowlistedLogEvents.contains(entry.eventName),
              let code = eventCodes[entry.eventName]
        else {
            return nil
        }

        var userInfo = sanitizedParameters(from: entry.metadata)
        userInfo["log_category"] = entry.category.rawValue
        userInfo["event_name"] = entry.eventName
        if let appVersion, !appVersion.isEmpty {
            userInfo["app_version"] = appVersion
        }

        return NSError(domain: errorDomain, code: code, userInfo: userInfo)
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
