import Foundation

/// Explains table grouping when attendance count is not a multiple of four.
enum PodLayoutHint {
    static func message(presentCount: Int, podSize: Int = AppConstants.League.podSize) -> String? {
        guard presentCount > 0, presentCount % podSize != 0 else { return nil }
        let remainder = presentCount % podSize
        let fullTables = presentCount / podSize
        if fullTables == 0 {
            return "\(presentCount) present — one table will seat \(presentCount) players."
        }
        let tableWord = fullTables == 1 ? "table" : "tables"
        return "\(presentCount) present — expect \(fullTables) \(tableWord) of \(podSize) and 1 table of \(remainder)."
    }
}
