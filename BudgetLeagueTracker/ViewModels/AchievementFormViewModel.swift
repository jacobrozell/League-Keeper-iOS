import Foundation
import SwiftData

/// ViewModel for creating or editing an achievement.
@Observable
final class AchievementFormViewModel {
    private let context: ModelContext
    let mode: AchievementFormMode

    var name: String = ""
    var achievementDescription: String = ""
    var points: Int = 1
    var alwaysOn: Bool = false
    var category: AchievementCategory = .custom
    var iconName: String = AppConstants.Achievement.defaultIconName
    var exclusivity: AchievementExclusivity = .unlimited
    var usesCustomPoints: Bool = false
    var iconManuallySelected: Bool = false

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?

    var navigationTitle: String {
        switch mode {
        case .add: return "New Achievement"
        case .edit: return "Edit Achievement"
        case .duplicate: return "Duplicate Achievement"
        }
    }

    var primaryActionTitle: String {
        switch mode {
        case .add, .duplicate: return "Add Achievement"
        case .edit: return "Save Changes"
        }
    }

    var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var selectedPointsTier: AchievementPointsTier {
        get { AchievementPointsTier.tier(for: points) ?? .small }
        set {
            usesCustomPoints = false
            points = newValue.points
        }
    }

    var descriptionCharacterCount: Int {
        achievementDescription.count
    }

    init(context: ModelContext, mode: AchievementFormMode) {
        self.context = context
        self.mode = mode
        applyModeDefaults()
    }

    func selectCategory(_ newCategory: AchievementCategory) {
        category = newCategory
        if !iconManuallySelected {
            iconName = newCategory.defaultIconName
        }
    }

    func selectIcon(_ newIconName: String) {
        iconManuallySelected = true
        iconName = AppConstants.Achievement.sanitizedIconName(newIconName)
    }

    func save() {
        guard canSave else { return }

        let trimmedDescription = achievementDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionOrNil = trimmedDescription.isEmpty ? nil : trimmedDescription

        switch mode {
        case .add, .duplicate:
            _ = LeagueEngine.addAchievement(
                context: context,
                name: name,
                points: points,
                alwaysOn: alwaysOn,
                achievementDescription: descriptionOrNil,
                category: category,
                iconName: iconName,
                exclusivity: exclusivity
            )
        case .edit(let achievementId):
            _ = LeagueEngine.updateAchievement(
                context: context,
                id: achievementId,
                name: name,
                points: points,
                alwaysOn: alwaysOn,
                achievementDescription: descriptionOrNil,
                category: category,
                iconName: iconName,
                exclusivity: exclusivity
            )
        }

        onSave?()
    }

    func cancel() {
        onCancel?()
    }

    private func applyModeDefaults() {
        switch mode {
        case .add(let template):
            if let template {
                apply(template: template)
            } else {
                resetToDefaults()
            }
        case .edit(let achievementId):
            if let achievement = LeagueEngine.fetchAchievement(context: context, id: achievementId) {
                apply(achievement: achievement)
                iconManuallySelected = true
            }
        case .duplicate(let achievementId):
            if let achievement = LeagueEngine.fetchAchievement(context: context, id: achievementId) {
                apply(achievement: achievement)
                iconManuallySelected = true
            }
        }
    }

    private func apply(template: AchievementTemplate) {
        name = template.name
        achievementDescription = template.achievementDescription
        points = template.points
        alwaysOn = template.alwaysOn
        category = template.category
        iconName = template.iconName
        exclusivity = template.exclusivity
        usesCustomPoints = AchievementPointsTier.tier(for: template.points) == nil
        iconManuallySelected = false
    }

    private func apply(achievement: Achievement) {
        name = achievement.name
        achievementDescription = achievement.achievementDescription ?? ""
        points = achievement.points
        alwaysOn = achievement.alwaysOn
        category = achievement.category
        iconName = achievement.iconName
        exclusivity = achievement.exclusivity
        usesCustomPoints = AchievementPointsTier.tier(for: achievement.points) == nil
    }

    private func resetToDefaults() {
        name = ""
        achievementDescription = ""
        points = AchievementPointsTier.small.points
        alwaysOn = false
        category = .custom
        iconName = AchievementCategory.custom.defaultIconName
        exclusivity = .unlimited
        usesCustomPoints = false
        iconManuallySelected = false
    }
}

/// Summary data for the achievements balance card.
struct AchievementBalanceSummary: Sendable {
    let catalogCount: Int
    let alwaysOnCount: Int
    let expectedActivePerWeek: Int
    let averagePoints: Double
    let guidanceMessage: String?
}
