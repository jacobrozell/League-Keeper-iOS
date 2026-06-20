import Foundation
import SwiftData

/// Version 1 schema — baseline for future SwiftData migrations.
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

/// Version 1.1 — league preset metadata, configurable table size, and placement scale.
enum LeagueKeeperSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 1, 0) }

    static var models: [any PersistentModel.Type] {
        LeagueKeeperSchemaV1.models
    }
}

enum LeagueKeeperMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LeagueKeeperSchemaV1.self, LeagueKeeperSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [MigrationStage.lightweight(fromVersion: LeagueKeeperSchemaV1.self, toVersion: LeagueKeeperSchemaV2.self)]
    }
}
