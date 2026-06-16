import Foundation
import SwiftData

/// Shared `ModelContainer` factory for the app, previews, and tests.
enum LeagueKeeperModelContainer {
    private static var schema: Schema {
        Schema([
            Player.self,
            Achievement.self,
            LeagueState.self,
            Tournament.self,
            GameResult.self,
        ])
    }

    static func make(isStoredInMemoryOnly: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let config: ModelConfiguration
        if let url {
            config = ModelConfiguration(url: url)
        } else {
            config = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        }
        return try ModelContainer(for: schema, configurations: [config])
    }
}
