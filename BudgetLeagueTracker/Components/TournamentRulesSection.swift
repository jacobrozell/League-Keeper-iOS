import SwiftUI

/// Stepper for dollar amounts shown as whole dollars.
struct DollarStepper: View {
    let title: String
    @Binding var dollars: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    var accessibilityLabel: String?

    private var canDecrement: Bool { dollars > range.lowerBound }
    private var canIncrement: Bool { dollars < range.upperBound }

    private var formattedAmount: String {
        dollars == 0 ? "Free" : TournamentRules.formatDollars(TournamentRules.cents(fromDollars: dollars))
    }

    var body: some View {
        HStack {
            Text("\(title): \(formattedAmount)")
                .font(.body)

            Spacer()

            HStack(spacing: 10) {
                Button {
                    if canDecrement {
                        dollars = max(range.lowerBound, dollars - step)
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.body.weight(.semibold))
                        .padding(10)
                        .frame(minWidth: AppConstants.UI.minTouchTargetHeight, minHeight: AppConstants.UI.minTouchTargetHeight)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.bordered)
                .disabled(!canDecrement)
                .accessibilityLabel("Decrease \(accessibilityLabel ?? title)")

                Button {
                    if canIncrement {
                        dollars = min(range.upperBound, dollars + step)
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .padding(10)
                        .frame(minWidth: AppConstants.UI.minTouchTargetHeight, minHeight: AppConstants.UI.minTouchTargetHeight)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.bordered)
                .disabled(!canIncrement)
                .accessibilityLabel("Increase \(accessibilityLabel ?? title)")
            }
        }
        .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityValue(formattedAmount)
    }
}

private struct DeckPricingSourcePicker: View {
    @Binding var selection: DeckPricingSource

    var body: some View {
        Picker("Reference pricing", selection: $selection) {
            ForEach(DeckPricingSource.allCases) { source in
                Text(source.displayName).tag(source)
            }
        }
    }
}

private struct RulesSummaryRow: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Compact tappable summary that opens the full house rules sheet.
struct TournamentRulesHintButton: View {
    let summary: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Text(summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("House rules, \(summary)")
        .accessibilityHint("Shows full tournament rules")
        .accessibilityIdentifier("Tournament Rules Hint")
    }
}

/// Editable tournament rules used in new/edit tournament flows.
struct TournamentRulesFormSection: View {
    @Binding var rules: TournamentRules

    @State private var entryFeeDollars: Int = AppConstants.TournamentRulesDefaults.entryFeeCents / 100
    @State private var deckBudgetDollars: Int = AppConstants.TournamentRulesDefaults.deckBudgetCents / 100
    @State private var maxCardPriceDollars: Int = AppConstants.TournamentRulesDefaults.maxCardPriceCents / 100
    @State private var limitsCommanderPrice: Bool = false
    @State private var commanderPriceDollars: Int = 50
    @State private var specifiesBracket: Bool = true
    @State private var targetBracket: Int = AppConstants.TournamentRulesDefaults.targetBracket

    var body: some View {
        Group {
            entryAndPrizesSection
            deckBudgetSection
            playstyleSection
        }
        .onAppear { loadFromRules() }
    }

    private var entryAndPrizesSection: some View {
        Section {
            DollarStepper(
                title: "Entry fee",
                dollars: $entryFeeDollars,
                range: AppConstants.TournamentRulesDefaults.entryFeeDollarsRange
            )
            .onChange(of: entryFeeDollars) { _, newValue in
                rules.entryFeeCents = TournamentRules.cents(fromDollars: newValue)
            }

            LabeledToggle(title: "Booster at sign-up", isOn: $rules.signupBoosterPrize)
            LabeledToggle(title: "Booster per pod winner", isOn: $rules.podWinnerBoosterPrize)
        } header: {
            Text("Entry & Prizes")
        } footer: {
            Text("Reference rules for your group. Players self-check decks — the app does not verify lists or prices.")
                .font(.caption)
        }
    }

    private var deckBudgetSection: some View {
        Section {
            DollarStepper(
                title: "Deck budget",
                dollars: $deckBudgetDollars,
                range: AppConstants.TournamentRulesDefaults.deckBudgetDollarsRange,
                step: 5
            )
            .onChange(of: deckBudgetDollars) { _, newValue in
                rules.deckBudgetCents = TournamentRules.cents(fromDollars: newValue)
            }

            DeckPricingSourcePicker(selection: $rules.pricingSource)

            DollarStepper(
                title: "Max single-card price",
                dollars: $maxCardPriceDollars,
                range: AppConstants.TournamentRulesDefaults.cardPriceDollarsRange
            )
            .onChange(of: maxCardPriceDollars) { _, newValue in
                rules.maxCardPriceCents = TournamentRules.cents(fromDollars: newValue)
            }

            LabeledToggle(
                title: "Commander excluded from budget",
                isOn: $rules.commanderExcludedFromBudget
            )
            LabeledToggle(
                title: "Basic lands excluded from budget",
                isOn: $rules.basicLandsExcludedFromBudget
            )

            LabeledToggle(
                title: "Limit commander price",
                isOn: $limitsCommanderPrice
            )
            .onChange(of: limitsCommanderPrice) { _, limited in
                rules.commanderPriceLimitCents = limited
                    ? TournamentRules.cents(fromDollars: commanderPriceDollars)
                    : nil
            }

            if limitsCommanderPrice {
                DollarStepper(
                    title: "Commander price limit",
                    dollars: $commanderPriceDollars,
                    range: AppConstants.TournamentRulesDefaults.commanderPriceDollarsRange
                )
                .onChange(of: commanderPriceDollars) { _, newValue in
                    if limitsCommanderPrice {
                        rules.commanderPriceLimitCents = TournamentRules.cents(fromDollars: newValue)
                    }
                }
            }
        } header: {
            Text("Deck Budget")
        } footer: {
            Text("Applies to the 99. Players use the reference source when checking their lists.")
                .font(.caption)
        }
    }

    private var playstyleSection: some View {
        Section {
            LabeledToggle(title: "Specify target bracket", isOn: $specifiesBracket)
                .onChange(of: specifiesBracket) { _, specified in
                    rules.targetBracket = specified ? targetBracket : nil
                }

            if specifiesBracket {
                LabeledStepper(
                    title: "Target bracket",
                    value: $targetBracket,
                    range: AppConstants.TournamentRulesDefaults.bracketRange
                )
                .onChange(of: targetBracket) { _, newValue in
                    if specifiesBracket {
                        rules.targetBracket = newValue
                    }
                }
            }

            TextField(
                "e.g. Keep it casual — aim for Bracket 2",
                text: $rules.playstyleNotes,
                axis: .vertical
            )
            .lineLimit(2...4)
            .onChange(of: rules.playstyleNotes) { _, newValue in
                let maxLength = AppConstants.TournamentRulesDefaults.playstyleNotesMaxLength
                if newValue.count > maxLength {
                    rules.playstyleNotes = String(newValue.prefix(maxLength))
                }
            }

            Button("Reset to defaults") {
                resetToDefaults()
            }
            .frame(minHeight: AppConstants.UI.minTouchTargetHeight)
        } header: {
            Text("Playstyle")
        } footer: {
            Text("Optional expectations for tone and power level. Brackets run 1 (exhibition) through 5 (cEDH).")
                .font(.caption)
        }
    }

    /// Restores Budget Commander defaults without affecting other tournament settings.
    func resetToDefaults() {
        rules = AppConstants.TournamentRulesDefaults.defaultRules
        loadFromRules()
    }

    private func loadFromRules(from source: TournamentRules? = nil) {
        let source = source ?? rules
        entryFeeDollars = TournamentRules.dollars(fromCents: source.entryFeeCents)
        deckBudgetDollars = TournamentRules.dollars(fromCents: source.deckBudgetCents)
        maxCardPriceDollars = TournamentRules.dollars(fromCents: source.maxCardPriceCents)

        if let commanderLimit = source.commanderPriceLimitCents {
            limitsCommanderPrice = true
            commanderPriceDollars = TournamentRules.dollars(fromCents: commanderLimit)
        } else {
            limitsCommanderPrice = false
            commanderPriceDollars = 50
        }

        if let bracket = source.targetBracket {
            specifiesBracket = true
            targetBracket = bracket
        } else {
            specifiesBracket = false
            targetBracket = AppConstants.TournamentRulesDefaults.targetBracket
        }
    }
}

/// Read-only summary of tournament rules.
struct TournamentRulesSummaryView: View {
    let rules: TournamentRules

    var body: some View {
        List {
            Section {
                Text(rules.compactSummary())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(Array(rules.summarySections().enumerated()), id: \.offset) { _, section in
                Section {
                    ForEach(Array(section.lines.enumerated()), id: \.offset) { _, line in
                        RulesSummaryRow(text: line)
                    }
                } header: {
                    Label(section.title, systemImage: section.iconName)
                }
            }

            Section {
                HintText(
                    message: "Players are trusted to build within these rules. The host can update them anytime in tournament settings."
                )
            }
        }
        .listStyle(.insetGrouped)
        .adaptiveContentWidth()
        .navigationTitle("House Rules")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("House Rules Summary")
    }
}

#Preview("Form") {
    List {
        TournamentRulesFormSection(rules: .constant(AppConstants.TournamentRulesDefaults.defaultRules))
    }
    .listStyle(.insetGrouped)
}

#Preview("Summary") {
    NavigationStack {
        TournamentRulesSummaryView(rules: AppConstants.TournamentRulesDefaults.defaultRules)
    }
}
