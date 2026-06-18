import Foundation

/// Reference source for card prices when players self-check deck budgets.
enum DeckPricingSource: String, Codable, CaseIterable, Identifiable, Sendable {
    case lowestOfTCGPlayerOrMoxfield
    case tcgPlayer
    case moxfield

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowestOfTCGPlayerOrMoxfield:
            return "Lowest of TCGPlayer or Moxfield"
        case .tcgPlayer:
            return "TCGPlayer"
        case .moxfield:
            return "Moxfield"
        }
    }
}

/// A titled group of lines in the rules summary.
struct TournamentRulesSummarySection: Equatable, Sendable {
    let title: String
    let iconName: String
    let lines: [String]
}

/// Per-tournament deck, prize, and playstyle rules.
struct TournamentRules: Codable, Equatable, Sendable {
    /// Entry fee in cents (e.g. 1000 = $10).
    var entryFeeCents: Int
    /// One booster pack for signing up.
    var signupBoosterPrize: Bool
    /// One booster pack for each pod winner.
    var podWinnerBoosterPrize: Bool
    /// Maximum deck budget in cents, excluding configured exemptions.
    var deckBudgetCents: Int
    var pricingSource: DeckPricingSource
    /// Maximum price for any card in the 99 (excluding commander), in cents.
    var maxCardPriceCents: Int
    var commanderExcludedFromBudget: Bool
    var basicLandsExcludedFromBudget: Bool
    /// Commander price cap in cents; `nil` means no limit.
    var commanderPriceLimitCents: Int?
    /// Target Commander bracket (1–5); `nil` when not specified.
    var targetBracket: Int?
    /// Free-form playstyle or house-rules notes.
    var playstyleNotes: String

    static var clientDefault: TournamentRules {
        AppConstants.TournamentRulesDefaults.defaultRules
    }

    /// Grouped summary for display in tournament detail.
    func summarySections() -> [TournamentRulesSummarySection] {
        [
            TournamentRulesSummarySection(
                title: "Entry & Prizes",
                iconName: "ticket",
                lines: entryAndPrizeLines()
            ),
            TournamentRulesSummarySection(
                title: "Deck Budget",
                iconName: "square.stack.3d.up",
                lines: deckBudgetLines()
            ),
            TournamentRulesSummarySection(
                title: "Playstyle",
                iconName: "sparkles",
                lines: playstyleLines()
            )
        ].filter { !$0.lines.isEmpty }
    }

    /// Short subtitle for headers and list context.
    func compactSummary() -> String {
        var parts: [String] = []
        parts.append(entryFeeCents == 0 ? "Free entry" : Self.formatDollars(entryFeeCents))
        parts.append("\(Self.formatDollars(deckBudgetCents)) budget")
        if let targetBracket {
            parts.append("Bracket \(targetBracket)")
        }
        return parts.joined(separator: " · ")
    }

    /// Flat summary lines (used by tests and accessibility).
    func summaryLines() -> [String] {
        summarySections().flatMap { section in
            [section.title] + section.lines
        }
    }

    private func entryAndPrizeLines() -> [String] {
        var lines = [formattedEntryFee]

        var prizes: [String] = []
        if signupBoosterPrize { prizes.append("1 booster at sign-up") }
        if podWinnerBoosterPrize { prizes.append("1 booster per pod winner") }
        if prizes.isEmpty {
            lines.append("No prizes configured")
        } else {
            lines.append(prizes.joined(separator: " · "))
        }

        return lines
    }

    private func deckBudgetLines() -> [String] {
        var lines = ["\(Self.formatDollars(deckBudgetCents)) total for the main deck"]

        var exclusions: [String] = []
        if commanderExcludedFromBudget { exclusions.append("commander") }
        if basicLandsExcludedFromBudget { exclusions.append("basic lands") }
        if !exclusions.isEmpty {
            lines.append("\(listPhrase(exclusions)) excluded from budget")
        }

        lines.append("Reference pricing: \(pricingSource.displayName)")
        lines.append("No single card over \(Self.formatDollars(maxCardPriceCents)) in the 99")

        if let commanderPriceLimitCents {
            lines.append("Commander capped at \(Self.formatDollars(commanderPriceLimitCents))")
        } else {
            lines.append("No commander price limit")
        }

        return lines
    }

    private func playstyleLines() -> [String] {
        var lines: [String] = []

        if let targetBracket {
            lines.append("Target Bracket \(targetBracket)")
        }

        let notes = playstyleNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        if !notes.isEmpty {
            lines.append(notes)
        }

        return lines
    }

    private var formattedEntryFee: String {
        entryFeeCents == 0 ? "Free entry" : "\(Self.formatDollars(entryFeeCents)) entry fee"
    }

    private func listPhrase(_ items: [String]) -> String {
        switch items.count {
        case 1: return items[0]
        case 2: return "\(items[0]) and \(items[1])"
        default:
            let head = items.dropLast().joined(separator: ", ")
            return "\(head), and \(items.last!)"
        }
    }

    static func formatDollars(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        if cents % 100 == 0 {
            return String(format: "$%.0f", dollars)
        }
        return String(format: "$%.2f", dollars)
    }

    static func dollars(fromCents cents: Int) -> Int {
        cents / 100
    }

    static func cents(fromDollars dollars: Int) -> Int {
        dollars * 100
    }
}
