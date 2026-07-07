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
    public var inactiveSurfaceWidth: Double
    public var inactiveSurfaceHeight: Double
    public var hoverSurfaceWidth: Double
    public var hoverSurfaceHeight: Double
    public var idleWidgetType: String
    public var selectedSpriteType: String
    
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
        customNotchHeight: Double = 24.0,
        inactiveSurfaceWidth: Double = 420.0,
        inactiveSurfaceHeight: Double = 64.0,
        hoverSurfaceWidth: Double = 560.0,
        hoverSurfaceHeight: Double = 118.0,
        idleWidgetType: String = "systemResources",
        selectedSpriteType: String = "cat"
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
        self.inactiveSurfaceWidth = inactiveSurfaceWidth
        self.inactiveSurfaceHeight = inactiveSurfaceHeight
        self.hoverSurfaceWidth = hoverSurfaceWidth
        self.hoverSurfaceHeight = hoverSurfaceHeight
        self.idleWidgetType = idleWidgetType
        self.selectedSpriteType = selectedSpriteType
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
        case inactiveSurfaceWidth
        case inactiveSurfaceHeight
        case hoverSurfaceWidth
        case hoverSurfaceHeight
        case idleWidgetType
        case selectedSpriteType
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
        self.inactiveSurfaceWidth = try container.decodeIfPresent(Double.self, forKey: .inactiveSurfaceWidth) ?? 420.0
        self.inactiveSurfaceHeight = try container.decodeIfPresent(Double.self, forKey: .inactiveSurfaceHeight) ?? 64.0
        self.hoverSurfaceWidth = try container.decodeIfPresent(Double.self, forKey: .hoverSurfaceWidth) ?? 560.0
        self.hoverSurfaceHeight = try container.decodeIfPresent(Double.self, forKey: .hoverSurfaceHeight) ?? 118.0
        self.idleWidgetType = try container.decodeIfPresent(String.self, forKey: .idleWidgetType) ?? "systemResources"
        self.selectedSpriteType = try container.decodeIfPresent(String.self, forKey: .selectedSpriteType) ?? "cat"
    }
}
