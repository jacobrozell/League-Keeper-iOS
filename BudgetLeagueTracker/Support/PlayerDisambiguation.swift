import Foundation

/// Resolves display labels when multiple players share the same name.
enum PlayerDisambiguation {
  /// Stable display name for lists, attendance, standings, and pickers.
  static func displayName(for player: Player, among players: [Player]) -> String {
    let note = sanitizedNote(player.nameNote)
    if let note {
      return "\(player.name) (\(note))"
    }

    let peers = players.filter {
      $0.name.compare(player.name, options: .caseInsensitive) == .orderedSame
    }
    guard peers.count > 1 else { return player.name }

    let sorted = peers.sorted { $0.id < $1.id }
    guard let index = sorted.firstIndex(where: { $0.id == player.id }) else {
      return player.name
    }
    return "\(player.name) (\(index + 1))"
  }

  /// Map of player id → display name for a roster.
  static func displayNames(for players: [Player]) -> [String: String] {
    Dictionary(uniqueKeysWithValues: players.map { player in
      (player.id, displayName(for: player, among: players))
    })
  }

  static func sanitizedNote(_ note: String?) -> String? {
    guard let note else { return nil }
    let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    return String(trimmed.prefix(AppConstants.Player.nameNoteMaxLength))
  }
}
