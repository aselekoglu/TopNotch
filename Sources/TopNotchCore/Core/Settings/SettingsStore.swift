import AppKit

@MainActor
public final class SettingsStore: ObservableObject, @unchecked Sendable {
    
    public static let shared = SettingsStore()
    
    @Published public private(set) var settings: AppSettings = AppSettings()
    
    public let storageURL: URL
    public private(set) var activeScreen: NSScreen?
    
    public init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        load()
    }
    
    // MARK: - API
    
    public static func screenIdentifier(_ screen: NSScreen) -> String {
        let name = screen.localizedName.isEmpty ? "Display" : screen.localizedName
        let width = Int(screen.frame.width)
        let height = Int(screen.frame.height)
        return "\(name) (\(width)x\(height))"
    }
    
    public func setActiveScreen(_ screen: NSScreen) {
        self.activeScreen = screen
        
        let id = Self.screenIdentifier(screen)
        var newSettings = settings
        
        if let screenSettings = settings.displaySettings[id] {
            // Load existing settings for this screen
            newSettings.customNotchWidth = screenSettings.customNotchWidth
            newSettings.customNotchHeight = screenSettings.customNotchHeight
            newSettings.inactiveSurfaceWidth = screenSettings.inactiveSurfaceWidth
            newSettings.inactiveSurfaceHeight = screenSettings.inactiveSurfaceHeight
            newSettings.hoverSurfaceWidth = screenSettings.hoverSurfaceWidth
            newSettings.hoverSurfaceHeight = screenSettings.hoverSurfaceHeight
            
            if newSettings != settings {
                update(settings: newSettings)
            }
        } else {
            // Initialize with current settings as default
            let screenSettings = DisplaySizeSettings(
                customNotchWidth: settings.customNotchWidth,
                customNotchHeight: settings.customNotchHeight,
                inactiveSurfaceWidth: settings.inactiveSurfaceWidth,
                inactiveSurfaceHeight: settings.inactiveSurfaceHeight,
                hoverSurfaceWidth: settings.hoverSurfaceWidth,
                hoverSurfaceHeight: settings.hoverSurfaceHeight
            )
            newSettings.displaySettings[id] = screenSettings
            update(settings: newSettings)
        }
    }
    
    public func update(settings: AppSettings) {
        var updated = settings
        if let screen = self.activeScreen {
            let id = Self.screenIdentifier(screen)
            let screenSettings = DisplaySizeSettings(
                customNotchWidth: settings.customNotchWidth,
                customNotchHeight: settings.customNotchHeight,
                inactiveSurfaceWidth: settings.inactiveSurfaceWidth,
                inactiveSurfaceHeight: settings.inactiveSurfaceHeight,
                hoverSurfaceWidth: settings.hoverSurfaceWidth,
                hoverSurfaceHeight: settings.hoverSurfaceHeight
            )
            updated.displaySettings[id] = screenSettings
        }
        self.settings = updated
        save()
    }
    
    public func resetToDefaults() {
        var defaultSettings = AppSettings()
        // If we reset, keep the other display settings but reset current display to defaults
        if let screen = self.activeScreen {
            let id = Self.screenIdentifier(screen)
            let defaults = AppSettings()
            let screenSettings = DisplaySizeSettings(
                customNotchWidth: defaults.customNotchWidth,
                customNotchHeight: defaults.customNotchHeight,
                inactiveSurfaceWidth: defaults.inactiveSurfaceWidth,
                inactiveSurfaceHeight: defaults.inactiveSurfaceHeight,
                hoverSurfaceWidth: defaults.hoverSurfaceWidth,
                hoverSurfaceHeight: defaults.hoverSurfaceHeight
            )
            defaultSettings.displaySettings = settings.displaySettings
            defaultSettings.displaySettings[id] = screenSettings
        }
        self.settings = defaultSettings
        save()
    }
    
    // MARK: - Persistence
    
    public func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(settings)
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            try data.write(to: storageURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist settings: \(error)")
        }
    }
    
    public func load() {
        let decoder = JSONDecoder()
        
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            self.settings = AppSettings()
            return
        }
        
        do {
            let data = try Data(contentsOf: storageURL)
            var decoded = try decoder.decode(AppSettings.self, from: data)
            let migrated = Self.migrateLegacySurfaceDefaultsIfNeeded(&decoded)
            self.settings = decoded
            if migrated {
                save()
            }
        } catch {
            // Falls back to default if missing or decoding fails
            self.settings = AppSettings()
            // Proactively save default settings back to disk if they couldn't be loaded or decoded
            save()
        }
    }
    
    // MARK: - Helpers
    
    private static func defaultStorageURL() -> URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return appSupport
            .appendingPathComponent("TopNotch", isDirectory: true)
            .appendingPathComponent("settings.json")
    }

    private static func migrateLegacySurfaceDefaultsIfNeeded(_ settings: inout AppSettings) -> Bool {
        guard settings.inactiveSurfaceWidth == 600.0,
              settings.inactiveSurfaceHeight == 88.0,
              settings.hoverSurfaceWidth == 720.0,
              settings.hoverSurfaceHeight == 150.0 else {
            return false
        }

        let defaults = AppSettings()
        settings.inactiveSurfaceWidth = defaults.inactiveSurfaceWidth
        settings.inactiveSurfaceHeight = defaults.inactiveSurfaceHeight
        settings.hoverSurfaceWidth = defaults.hoverSurfaceWidth
        settings.hoverSurfaceHeight = defaults.hoverSurfaceHeight
        return true
    }
}
