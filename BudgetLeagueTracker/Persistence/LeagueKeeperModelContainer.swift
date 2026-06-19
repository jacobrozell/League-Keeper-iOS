import Foundation
import SwiftData

/// Shared `ModelContainer` factory for the app, previews, and tests.
enum LeagueKeeperModelContainer {
    static func make(isStoredInMemoryOnly: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let config: ModelConfiguration
        if let url {
            config = ModelConfiguration(url: url)
        } else {
            config = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        }
        return try ModelContainer(
            for: Schema(versionedSchema: LeagueKeeperSchemaV1.self),
            migrationPlan: LeagueKeeperMigrationPlan.self,
            configurations: [config]
        )
    }
}
