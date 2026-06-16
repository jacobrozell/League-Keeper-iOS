import Foundation

public enum AnalyticsMetadataKeys {
    public static let defaultRedactionAllowed: Set<String> = [
        "errorCode",
        "operation",
        "schemaVersion",
        "weekNumber",
        "playerCount",
        "status",
        "source"
    ]

    public static let firebaseParameters: Set<String> = defaultRedactionAllowed
}
