import SwiftUI

/// First-launch welcome flow — local-first intro, weekly workflow, and quick-start actions.
@MainActor
struct OnboardingView: View {
    enum Completion {
        case dismiss
        case loadSample
        case createTournament
    }

    var onComplete: (Completion) -> Void

    @Environment(\.palette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var page = 0

    @ScaledMetric(relativeTo: .title2) private var heroDiameter: CGFloat = 112
    @ScaledMetric(relativeTo: .title) private var heroIconSize: CGFloat = 48

    private struct Page: Identifiable {
        let id: Int
        let symbol: String
        let title: String
        let subtitle: String
        let body: String
    }

    private let pages: [Page] = [
        Page(
            id: 0,
            symbol: "trophy.fill",
            title: AppInfo.displayName,
            subtitle: "Your league scorekeeper",
            body: "Track Magic game nights on your iPhone or iPad — who's playing, table seating, finish order, bonus achievements, and weekly standings."
        ),
        Page(
            id: 1,
            symbol: "lock.iphone",
            title: "Stays on your device",
            subtitle: "No account required",
            body: "Players, tournaments, and standings stay on this device. Nothing is uploaded or synced to a server."
        ),
        Page(
            id: 2,
            symbol: "calendar.badge.clock",
            title: "Each game night in three steps",
            subtitle: "Attendance → Seating → Scoring",
            body: "Mark who showed up, seat players at tables of four, then record finish order and any bonus achievements. Review standings when the night is done."
        ),
        Page(
            id: 3,
            symbol: "sparkles",
            title: "You're ready",
            subtitle: "Start with a sample or your own league",
            body: "New here? Try the sample league to walk through a week. When you're ready, create a tournament with your own players and rules."
        ),
    ]

    private var largeText: Bool { dynamicTypeSize.isAccessibilitySize }
    private var compactHeight: Bool { verticalSizeClass == .compact }
    private var widePageLayout: Bool {
        (compactHeight || horizontalSizeClass == .regular) && !largeText
    }
    private var contentMaxWidth: CGFloat { widePageLayout ? AdaptiveLayout.contentMaxWidth : .infinity }

    private var horizontalPadding: CGFloat {
        if widePageLayout { return 32 }
        return largeText ? 20 : 28
    }

    private var effectiveHeroDiameter: CGFloat {
        if widePageLayout { return min(heroDiameter, 72) }
        if largeText { return min(heroDiameter, 80) }
        return min(heroDiameter, 128)
    }

    private var effectiveHeroIconSize: CGFloat {
        if widePageLayout { return min(heroIconSize, 32) }
        if largeText { return min(heroIconSize, 36) }
        return min(heroIconSize, 52)
    }

    var body: some View {
        ZStack {
            onboardingBackground
                .ignoresSafeArea()

            NavigationStack {
                TabView(selection: $page) {
                    ForEach(pages) { item in
                        pageContent(item)
                            .tag(item.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    footer
                        .padding(.horizontal, widePageLayout ? 32 : 24)
                        .padding(.top, compactHeight ? 8 : 12)
                        .padding(.bottom, compactHeight ? 10 : 16)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if page < pages.count - 1 {
                            Button("Skip") { onComplete(.dismiss) }
                                .accessibilityIdentifier("onboardingSkip")
                        }
                    }
                }
            }
            .accessibilityIdentifier("onboardingScreen")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func pageContent(_ item: Page) -> some View {
        ScrollView {
            Group {
                if widePageLayout {
                    HStack(alignment: .center, spacing: 28) {
                        heroMark(for: item)
                        textBlock(item, alignment: .leading)
                    }
                } else {
                    VStack(spacing: largeText ? 20 : 28) {
                        heroMark(for: item)
                            .padding(.top, largeText ? 4 : 16)
                        textBlock(item, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, widePageLayout ? 8 : 0)
            .padding(.bottom, 8)

            if item.id == 3 {
                featureHighlights(twoColumn: widePageLayout)
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 8)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func textBlock(_ item: Page, alignment: TextAlignment) -> some View {
        VStack(spacing: 10) {
            Text(item.title)
                .font(.system(widePageLayout ? .title : .largeTitle, design: .serif).weight(.bold))
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(item.subtitle)
                .font(widePageLayout ? .headline.weight(.medium) : .title3.weight(.medium))
                .foregroundStyle(Color(hex: palette.gold))
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }

    private func featureHighlights(twoColumn: Bool) -> some View {
        let rows: [(String, String)] = [
            ("trophy.fill", "Tournaments — multi-week seasons with weekly game nights"),
            ("person.crop.rectangle.stack", "Players — one roster shared across tournaments"),
            ("chart.bar", "Stats — wins, placement points, and achievements"),
            ("star.fill", "Achievements — custom bonus points each game"),
        ]

        return Group {
            if twoColumn {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        highlightRow(row.0, row.1)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        highlightRow(row.0, row.1)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func highlightRow(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(hex: palette.gold))
                .frame(minWidth: 24, alignment: .center)
                .accessibilityHidden(true)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func heroMark(for item: Page) -> some View {
        if item.id == 0 {
            ZStack {
                Circle()
                    .fill(Color(hex: palette.gold).opacity(0.14))
                    .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
                Circle()
                    .strokeBorder(Color(hex: palette.gold).opacity(0.28), lineWidth: 1)
                    .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
                BrandCrest(size: effectiveHeroDiameter * 0.72, clipStyle: .circle)
            }
            .accessibilityLabel(AppInfo.displayName)
        } else {
            heroSymbol(item.symbol)
        }
    }

    private func heroSymbol(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(hex: palette.gold).opacity(0.14))
                .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
            Circle()
                .strokeBorder(Color(hex: palette.gold).opacity(0.28), lineWidth: 1)
                .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
            Image(systemName: name)
                .font(.system(size: effectiveHeroIconSize, weight: .medium))
                .foregroundStyle(Color(hex: palette.gold))
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var footer: some View {
        if widePageLayout {
            wideFooter
        } else {
            stackedFooter
        }
    }

    private var stackedFooter: some View {
        VStack(spacing: largeText ? 12 : 16) {
            pageIndicator
            footerActions
        }
    }

    private var wideFooter: some View {
        VStack(spacing: 10) {
            if page < pages.count - 1 {
                HStack(spacing: 16) {
                    pageIndicator
                    Spacer(minLength: 0)
                    Button("Continue") { page += 1 }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .accessibilityIdentifier("onboardingContinue")
                }
            } else {
                VStack(spacing: 12) {
                    Button("Try sample league") { onComplete(.loadSample) }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("onboardingLoadSample")

                    Button("Create my tournament") { onComplete(.createTournament) }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("onboardingCreateTournament")
                }

                HStack(spacing: 12) {
                    pageIndicator
                    Spacer(minLength: 0)
                    Button("Set up later") { onComplete(.dismiss) }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("onboardingContinue")
                }
            }
        }
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var footerActions: some View {
        if page < pages.count - 1 {
            Button("Continue") { page += 1 }
                .buttonStyle(.borderedProminent)
                .controlSize(largeText ? .regular : .large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("onboardingContinue")
        } else {
            VStack(spacing: 10) {
                Button("Try sample league") { onComplete(.loadSample) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(largeText ? .regular : .large)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("onboardingLoadSample")

                Button("Create my tournament") { onComplete(.createTournament) }
                    .buttonStyle(.bordered)
                    .controlSize(largeText ? .regular : .large)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("onboardingCreateTournament")

                Button("Set up later") { onComplete(.dismiss) }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .accessibilityIdentifier("onboardingContinue")
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { item in
                Capsule()
                    .fill(item.id == page ? Color(hex: palette.gold) : Color.secondary.opacity(0.25))
                    .frame(width: item.id == page ? 22 : 8, height: 8)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: page)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(page + 1) of \(pages.count)")
    }

    private var onboardingBackground: some View {
        ZStack {
            Color(hex: palette.bg)
            RadialGradient(
                colors: [
                    Color(hex: palette.gold).opacity(0.12),
                    Color(hex: palette.bg).opacity(0),
                ],
                center: compactHeight ? .leading : .top,
                startRadius: 40,
                endRadius: 420
            )
        }
    }
}

#Preview("Default") {
    OnboardingView { _ in }
        .preferredColorScheme(.dark)
}

#Preview("iPad", traits: .landscapeLeft) {
    OnboardingView { _ in }
}

#Preview("Landscape", traits: .landscapeLeft) {
    OnboardingView { _ in }
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    OnboardingView { _ in }
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}
