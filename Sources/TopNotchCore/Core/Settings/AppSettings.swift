import Foundation

public struct AppSettings: Equatable, Sendable, Codable {
    public var visibleModuleIdentifiers: [String]
    public var enableHoverAffordance: Bool
    public var enableLiveActivityExpansion: Bool
    public var forceVirtualIslandStyle: Bool
    public var clipboardMaxItemsCount: Int
    public var clipboardMaxAgeDays: Int
    public var excludedAppBundleIdentifiers: Set<String>
    public var notesMaxPinnedCount: Int
    
    public init(
        visibleModuleIdentifiers: [String] = ["music", "clipboard", "notes"],
        enableHoverAffordance: Bool = true,
        enableLiveActivityExpansion: Bool = true,
        forceVirtualIslandStyle: Bool = false,
        clipboardMaxItemsCount: Int = 100,
        clipboardMaxAgeDays: Int = 30,
        excludedAppBundleIdentifiers: Set<String> = [],
        notesMaxPinnedCount: Int = 8
    ) {
        self.visibleModuleIdentifiers = visibleModuleIdentifiers
        self.enableHoverAffordance = enableHoverAffordance
        self.enableLiveActivityExpansion = enableLiveActivityExpansion
        self.forceVirtualIslandStyle = forceVirtualIslandStyle
        self.clipboardMaxItemsCount = clipboardMaxItemsCount
        self.clipboardMaxAgeDays = clipboardMaxAgeDays
        self.excludedAppBundleIdentifiers = excludedAppBundleIdentifiers
        self.notesMaxPinnedCount = notesMaxPinnedCount
    }
}
