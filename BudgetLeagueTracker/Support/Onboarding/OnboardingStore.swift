import Foundation

/// Persists whether the user has finished the first-launch welcome flow.
struct OnboardingStore {
    static let completedKey = "onboarding_completed"
    static let skipLaunchArgument = "-skip_onboarding"
    static let uiTestOnboardingLaunchArgument = "UI-Testing-Onboarding"

    let userDefaults: UserDefaults
    let isEnabled: Bool

    init(
        userDefaults: UserDefaults = .standard,
        isEnabled: Bool = OnboardingStore.defaultIsEnabled
    ) {
        self.userDefaults = userDefaults
        self.isEnabled = isEnabled
    }

    static var defaultIsEnabled: Bool {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains(uiTestOnboardingLaunchArgument) {
            return true
        }
        if arguments.contains(skipLaunchArgument) || AppInfo.isUITesting {
            return false
        }
        return true
    }

    var isCompleted: Bool {
        userDefaults.bool(forKey: Self.completedKey)
    }

    var shouldPresentOnLaunch: Bool {
        isEnabled && !isCompleted
    }

    func markCompleted() {
        userDefaults.set(true, forKey: Self.completedKey)
    }

    func clearCompleted() {
        userDefaults.removeObject(forKey: Self.completedKey)
    }
}
