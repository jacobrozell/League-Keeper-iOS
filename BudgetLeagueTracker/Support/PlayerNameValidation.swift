import Foundation
import SwiftData

/// Shared validation for player display names.
enum PlayerNameValidation {
  static func validate(name: String) -> String? {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "Name cannot be empty." }
    return nil
  }

  /// Whether another roster member already uses this name (informational only).
  static func hasSameName(
    context: ModelContext,
    name: String,
    excludingPlayerId: String? = nil
  ) -> Bool {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    let descriptor = FetchDescriptor<Player>()
    let players = (try? context.fetch(descriptor)) ?? []
    return players.contains {
      $0.id != excludingPlayerId
        && $0.name.compare(trimmed, options: .caseInsensitive) == .orderedSame
    }
  }
}
