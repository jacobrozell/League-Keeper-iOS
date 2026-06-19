import Foundation
import SwiftData

/// User-facing persistence failure.
enum PersistenceError: LocalizedError, Equatable {
    case saveFailed

    var errorDescription: String? {
        "Couldn't save your changes. Try again."
    }

    var toastMessage: String {
        "Couldn't save — try again"
    }
}

/// Centralized SwiftData save with Crashlytics logging on failure.
enum PersistenceSave {
    enum Event: String {
        case tournament = "tournament_save_failed"
        case round = "round_save_failed"
    }

    @discardableResult
    static func save(context: ModelContext, event: Event = .tournament) -> Bool {
        do {
            try context.save()
            return true
        } catch {
            AppLog.shared.error(
                .persistence,
                eventName: event.rawValue,
                message: "SwiftData save failed",
                metadata: ["errorDescription": String(describing: error)]
            )
            return false
        }
    }
}
