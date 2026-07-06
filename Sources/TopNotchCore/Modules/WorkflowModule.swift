import Foundation

/// Unique identifiers for all workspace modules in Top Notch.
public enum ModuleIdentifier: String, Codable, Sendable, CaseIterable {
    case music
    case clipboard
    case notes
    case calendar
    case timer
    case fileDrop
    case quickCommands
    case agents
}

/// Represents a configuration-driven module in the system, shared by active and planned features.
public struct WorkflowModule: Identifiable, Equatable, Sendable {
    /// The unique type identifier.
    public var id: ModuleIdentifier { identifier }
    public let identifier: ModuleIdentifier
    
    /// User-facing name of the module.
    public let name: String
    
    /// SF Symbols icon name.
    public let iconName: String
    
    /// If true, this module is not yet active in the MVP and routes to a disabled UI.
    public let isPlannedOnly: Bool
    
    /// User-configurable visibility in settings.
    public var isVisible: Bool
    
    public init(
        identifier: ModuleIdentifier,
        name: String,
        iconName: String,
        isPlannedOnly: Bool,
        isVisible: Bool = true
    ) {
        self.identifier = identifier
        self.name = name
        self.iconName = iconName
        self.isPlannedOnly = isPlannedOnly
        self.isVisible = isVisible
    }
}
