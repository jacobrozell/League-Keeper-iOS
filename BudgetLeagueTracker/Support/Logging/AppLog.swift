import Foundation

public enum AppLog {
    public static let shared: AppLogger = DefaultAppLogger.makeForCurrentBuild()
}
