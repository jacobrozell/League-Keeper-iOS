import Foundation

public protocol RedactionPolicy: Sendable {
    func redact(metadata: [String: String]) -> [String: String]
}

public struct DefaultRedactionPolicy: RedactionPolicy {
    private let allowedMetadataKeys: Set<String>

    public init(allowedMetadataKeys: Set<String> = AnalyticsMetadataKeys.defaultRedactionAllowed) {
        self.allowedMetadataKeys = allowedMetadataKeys
    }

    public func redact(metadata: [String: String]) -> [String: String] {
        metadata.reduce(into: [:]) { result, pair in
            guard allowedMetadataKeys.contains(pair.key) else { return }
            result[pair.key] = pair.value
        }
    }
}
