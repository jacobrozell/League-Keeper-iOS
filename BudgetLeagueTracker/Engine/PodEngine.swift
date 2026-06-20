import Foundation

/// Table seating generation for weekly rounds.
enum PodEngine {
    static func generatePodsForRound(
        players: [Player],
        presentPlayerIds: [String],
        currentRound: Int,
        standingsBasedSeating: Bool = AppConstants.League.defaultStandingsBasedSeating,
        previousRoundPlacements: [String: Int] = [:],
        forceRandom: Bool = false,
        podSize: Int = AppConstants.League.defaultPlayersPerTable
    ) -> [[Player]] {
        let presentPlayers = players.filter { presentPlayerIds.contains($0.id) }
        guard !presentPlayers.isEmpty else { return [] }

        let tableSize = min(
            max(podSize, AppConstants.League.playersPerTableRange.lowerBound),
            AppConstants.League.playersPerTableRange.upperBound
        )
        let useRandomSeating = forceRandom
            || currentRound == 1
            || !standingsBasedSeating
            || previousRoundPlacements.isEmpty

        if useRandomSeating {
            return chunkIntoPods(presentPlayers.shuffled(), podSize: tableSize)
        }

        return podsGroupedByPreviousPlacement(
            presentPlayers: presentPlayers,
            previousPlacements: previousRoundPlacements,
            podSize: tableSize
        )
    }

    static func podsGroupedByPreviousPlacement(
        presentPlayers: [Player],
        previousPlacements: [String: Int],
        podSize: Int
    ) -> [[Player]] {
        var groups: [Int: [Player]] = [:]
        for player in presentPlayers {
            let place = previousPlacements[player.id] ?? podSize
            let clampedPlace = min(max(place, 1), podSize)
            groups[clampedPlace, default: []].append(player)
        }

        var pods: [[Player]] = []
        for place in 1...podSize {
            guard var group = groups[place], !group.isEmpty else { continue }
            group.shuffle()
            pods.append(group)
        }
        return pods
    }

    static func chunkIntoPods(_ sortedPlayers: [Player], podSize: Int) -> [[Player]] {
        var pods: [[Player]] = []
        var currentPod: [Player] = []

        for player in sortedPlayers {
            currentPod.append(player)
            if currentPod.count == podSize {
                pods.append(currentPod)
                currentPod = []
            }
        }

        if !currentPod.isEmpty {
            pods.append(currentPod)
        }

        return pods
    }
}
