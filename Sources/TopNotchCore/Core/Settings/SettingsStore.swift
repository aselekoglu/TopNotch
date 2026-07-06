import Foundation

@MainActor
public final class SettingsStore: ObservableObject, @unchecked Sendable {
    
    public static let shared = SettingsStore()
    
    @Published public private(set) var settings: AppSettings = AppSettings()
    
    public let storageURL: URL
    
    public init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        load()
    }
    
    // MARK: - API
    
    public func update(settings: AppSettings) {
        self.settings = settings
        save()
    }
    
    public func resetToDefaults() {
        self.settings = AppSettings()
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
            self.settings = try decoder.decode(AppSettings.self, from: data)
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
}
