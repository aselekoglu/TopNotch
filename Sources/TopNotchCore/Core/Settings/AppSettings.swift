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
    public var targetDisplayIndex: Int
    public var customNotchWidth: Double
    public var customNotchHeight: Double
    
    public init(
        visibleModuleIdentifiers: [String] = ["music", "clipboard", "notes"],
        enableHoverAffordance: Bool = true,
        enableLiveActivityExpansion: Bool = true,
        forceVirtualIslandStyle: Bool = false,
        clipboardMaxItemsCount: Int = 100,
        clipboardMaxAgeDays: Int = 30,
        excludedAppBundleIdentifiers: Set<String> = [],
        notesMaxPinnedCount: Int = 8,
        targetDisplayIndex: Int = 0,
        customNotchWidth: Double = 180.0,
        customNotchHeight: Double = 24.0
    ) {
        self.visibleModuleIdentifiers = visibleModuleIdentifiers
        self.enableHoverAffordance = enableHoverAffordance
        self.enableLiveActivityExpansion = enableLiveActivityExpansion
        self.forceVirtualIslandStyle = forceVirtualIslandStyle
        self.clipboardMaxItemsCount = clipboardMaxItemsCount
        self.clipboardMaxAgeDays = clipboardMaxAgeDays
        self.excludedAppBundleIdentifiers = excludedAppBundleIdentifiers
        self.notesMaxPinnedCount = notesMaxPinnedCount
        self.targetDisplayIndex = targetDisplayIndex
        self.customNotchWidth = customNotchWidth
        self.customNotchHeight = customNotchHeight
    }
    
    private enum CodingKeys: String, CodingKey {
        case visibleModuleIdentifiers
        case enableHoverAffordance
        case enableLiveActivityExpansion
        case forceVirtualIslandStyle
        case clipboardMaxItemsCount
        case clipboardMaxAgeDays
        case excludedAppBundleIdentifiers
        case notesMaxPinnedCount
        case targetDisplayIndex
        case customNotchWidth
        case customNotchHeight
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.visibleModuleIdentifiers = try container.decodeIfPresent([String].self, forKey: .visibleModuleIdentifiers) ?? ["music", "clipboard", "notes"]
        self.enableHoverAffordance = try container.decodeIfPresent(Bool.self, forKey: .enableHoverAffordance) ?? true
        self.enableLiveActivityExpansion = try container.decodeIfPresent(Bool.self, forKey: .enableLiveActivityExpansion) ?? true
        self.forceVirtualIslandStyle = try container.decodeIfPresent(Bool.self, forKey: .forceVirtualIslandStyle) ?? false
        self.clipboardMaxItemsCount = try container.decodeIfPresent(Int.self, forKey: .clipboardMaxItemsCount) ?? 100
        self.clipboardMaxAgeDays = try container.decodeIfPresent(Int.self, forKey: .clipboardMaxAgeDays) ?? 30
        self.excludedAppBundleIdentifiers = try container.decodeIfPresent(Set<String>.self, forKey: .excludedAppBundleIdentifiers) ?? []
        self.notesMaxPinnedCount = try container.decodeIfPresent(Int.self, forKey: .notesMaxPinnedCount) ?? 8
        self.targetDisplayIndex = try container.decodeIfPresent(Int.self, forKey: .targetDisplayIndex) ?? 0
        self.customNotchWidth = try container.decodeIfPresent(Double.self, forKey: .customNotchWidth) ?? 180.0
        self.customNotchHeight = try container.decodeIfPresent(Double.self, forKey: .customNotchHeight) ?? 24.0
    }
}
