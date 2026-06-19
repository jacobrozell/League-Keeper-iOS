import Foundation

/// Represents the current screen/view in the app navigation flow.
/// Persisted in LeagueState for state restoration.
enum Screen: String, Codable, CaseIterable {
    case tournaments
    case newTournament
    case attendance
    case tournamentStandings
    case tournamentDetail

    /// Maps legacy persisted screen values to the current navigation model.
    static func migrated(from rawValue: String) -> Screen {
        switch rawValue {
        case "dashboard", "pods":
            return .tournaments
        case "confirmNewTournament", "addPlayers":
            return .newTournament
        default:
            return Screen(rawValue: rawValue) ?? .tournaments
        }
    }
}
