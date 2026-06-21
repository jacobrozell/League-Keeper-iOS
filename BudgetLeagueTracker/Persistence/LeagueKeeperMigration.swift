import Foundation
import SwiftData

/// Version 1 schema — baseline for future SwiftData migrations.
///
/// When the model graph changes, add a new `VersionedSchema` whose `models`
/// actually differ from this one (otherwise the schema checksums collide and
/// SwiftData throws "Duplicate version checksums detected" during migration),
/// then append a `MigrationStage` to the plan below.
enum LeagueKeeperSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            Player.self,
            Achievement.self,
            LeagueState.self,
            Tournament.self,
            GameResult.self,
        ]
    }
}

enum LeagueKeeperMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LeagueKeeperSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
