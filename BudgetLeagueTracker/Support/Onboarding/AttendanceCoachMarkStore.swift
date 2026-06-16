import Foundation

/// Persists whether the host has seen the first-week attendance tip on tournament detail.
struct AttendanceCoachMarkStore {
    static let seenKey = "attendance_coach_mark_seen"

    let userDefaults: UserDefaults
    let isEnabled: Bool

    init(
        userDefaults: UserDefaults = .standard,
        isEnabled: Bool = AttendanceCoachMarkStore.defaultIsEnabled
    ) {
        self.userDefaults = userDefaults
        self.isEnabled = isEnabled
    }

    static var defaultIsEnabled: Bool {
        if AppInfo.isUITesting { return false }
        if ProcessInfo.processInfo.arguments.contains(OnboardingStore.skipLaunchArgument) {
            return false
        }
        return true
    }

    var hasSeenCoachMark: Bool {
        userDefaults.bool(forKey: Self.seenKey)
    }

    var shouldShowCoachMark: Bool {
        isEnabled && !hasSeenCoachMark
    }

    func markSeen() {
        userDefaults.set(true, forKey: Self.seenKey)
    }

    func clearSeen() {
        userDefaults.removeObject(forKey: Self.seenKey)
    }
}
