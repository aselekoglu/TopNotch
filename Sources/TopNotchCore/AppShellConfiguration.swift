import Foundation

public struct AppShellConfiguration: Equatable, Sendable {
    public let appName: String
    public let processName: String
    public let launchesWithoutMainWindow: Bool
    public let hasSettingsWindow: Bool

    public init(
        appName: String,
        processName: String,
        launchesWithoutMainWindow: Bool,
        hasSettingsWindow: Bool
    ) {
        self.appName = appName
        self.processName = processName
        self.launchesWithoutMainWindow = launchesWithoutMainWindow
        self.hasSettingsWindow = hasSettingsWindow
    }

    public static let taskOneDefault = AppShellConfiguration(
        appName: "Top Notch",
        processName: "TopNotch",
        launchesWithoutMainWindow: true,
        hasSettingsWindow: true
    )
}
