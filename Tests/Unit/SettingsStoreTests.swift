import XCTest
import Combine
@testable import TopNotchCore

@MainActor
final class SettingsStoreTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    private func tempStorageURL() -> URL {
        let fileName = "settings_test_\(UUID().uuidString).json"
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
    }
    
    private func makeStore(storageURL: URL? = nil) -> SettingsStore {
        SettingsStore(storageURL: storageURL ?? tempStorageURL())
    }
    
    func testDefaultSettingsInitialization() {
        let store = makeStore()
        XCTAssertEqual(store.settings.visibleModuleIdentifiers, ["music", "clipboard", "notes"])
        XCTAssertTrue(store.settings.enableHoverAffordance)
        XCTAssertTrue(store.settings.enableLiveActivityExpansion)
        XCTAssertFalse(store.settings.forceVirtualIslandStyle)
        XCTAssertEqual(store.settings.clipboardMaxItemsCount, 100)
        XCTAssertEqual(store.settings.clipboardMaxAgeDays, 30)
        XCTAssertTrue(store.settings.excludedAppBundleIdentifiers.isEmpty)
        XCTAssertEqual(store.settings.notesMaxPinnedCount, 8)
        XCTAssertEqual(store.settings.targetDisplayIndex, 0)
        XCTAssertEqual(store.settings.customNotchWidth, 180.0)
        XCTAssertEqual(store.settings.customNotchHeight, 24.0)
        XCTAssertEqual(store.settings.inactiveSurfaceWidth, 420.0)
        XCTAssertEqual(store.settings.inactiveSurfaceHeight, 64.0)
        XCTAssertEqual(store.settings.hoverSurfaceWidth, 560.0)
        XCTAssertEqual(store.settings.hoverSurfaceHeight, 118.0)
        XCTAssertEqual(store.settings.idleWidgetType, "systemResources")
        XCTAssertEqual(store.settings.selectedSpriteType, "cat")
    }
    
    func testUpdatingSettingsFiresPublisher() {
        let store = makeStore()
        var receivedSettings: [AppSettings] = []
        
        store.$settings
            .dropFirst() // Drop the initial value during subscription
            .sink { receivedSettings.append($0) }
            .store(in: &cancellables)
            
        var newSettings = AppSettings()
        newSettings.visibleModuleIdentifiers = ["clipboard"]
        newSettings.enableHoverAffordance = false
        newSettings.clipboardMaxItemsCount = 50
        
        store.update(settings: newSettings)
        
        XCTAssertEqual(receivedSettings.count, 1)
        XCTAssertEqual(receivedSettings.first, newSettings)
        XCTAssertEqual(store.settings, newSettings)
    }
    
    func testPersistenceRoundtrip() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        
        var newSettings = AppSettings()
        newSettings.visibleModuleIdentifiers = ["music"]
        newSettings.enableHoverAffordance = false
        newSettings.enableLiveActivityExpansion = false
        newSettings.forceVirtualIslandStyle = true
        newSettings.clipboardMaxItemsCount = 200
        newSettings.clipboardMaxAgeDays = 14
        newSettings.excludedAppBundleIdentifiers = ["com.apple.Terminal"]
        newSettings.notesMaxPinnedCount = 10
        newSettings.targetDisplayIndex = 2
        newSettings.customNotchWidth = 250.0
        newSettings.customNotchHeight = 35.0
        newSettings.inactiveSurfaceWidth = 640.0
        newSettings.inactiveSurfaceHeight = 96.0
        newSettings.hoverSurfaceWidth = 760.0
        newSettings.hoverSurfaceHeight = 160.0
        newSettings.idleWidgetType = "retroSprite"
        newSettings.selectedSpriteType = "ghost"
        
        store.update(settings: newSettings)
        
        let reloadedStore = makeStore(storageURL: url)
        XCTAssertEqual(reloadedStore.settings, newSettings)
        
        try? FileManager.default.removeItem(at: url)
    }
 
    func testBackwardCompatibleDecodeDefaultsMissingSurfaceSizes() throws {
        let json = """
        {
          "visibleModuleIdentifiers": ["music", "clipboard", "notes"],
          "enableHoverAffordance": true,
          "enableLiveActivityExpansion": true,
          "forceVirtualIslandStyle": false,
          "clipboardMaxItemsCount": 100,
          "clipboardMaxAgeDays": 30,
          "excludedAppBundleIdentifiers": [],
          "notesMaxPinnedCount": 8,
          "targetDisplayIndex": 0,
          "customNotchWidth": 180.0,
          "customNotchHeight": 24.0
        }
        """
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)
 
        XCTAssertEqual(decoded.inactiveSurfaceWidth, 420.0)
        XCTAssertEqual(decoded.inactiveSurfaceHeight, 64.0)
        XCTAssertEqual(decoded.hoverSurfaceWidth, 560.0)
        XCTAssertEqual(decoded.hoverSurfaceHeight, 118.0)
        XCTAssertEqual(decoded.idleWidgetType, "systemResources")
        XCTAssertEqual(decoded.selectedSpriteType, "cat")
    }

    func testLoadMigratesLegacySurfaceDefaultsToCompactDefaults() throws {
        let url = tempStorageURL()
        let json = """
        {
          "visibleModuleIdentifiers": ["music", "clipboard", "notes"],
          "enableHoverAffordance": true,
          "enableLiveActivityExpansion": true,
          "forceVirtualIslandStyle": false,
          "clipboardMaxItemsCount": 100,
          "clipboardMaxAgeDays": 30,
          "excludedAppBundleIdentifiers": [],
          "notesMaxPinnedCount": 8,
          "targetDisplayIndex": 0,
          "customNotchWidth": 180.0,
          "customNotchHeight": 24.0,
          "inactiveSurfaceWidth": 600.0,
          "inactiveSurfaceHeight": 88.0,
          "hoverSurfaceWidth": 720.0,
          "hoverSurfaceHeight": 150.0
        }
        """
        try Data(json.utf8).write(to: url)

        let store = makeStore(storageURL: url)

        XCTAssertEqual(store.settings.inactiveSurfaceWidth, 420.0)
        XCTAssertEqual(store.settings.inactiveSurfaceHeight, 64.0)
        XCTAssertEqual(store.settings.hoverSurfaceWidth, 560.0)
        XCTAssertEqual(store.settings.hoverSurfaceHeight, 118.0)

        try? FileManager.default.removeItem(at: url)
    }
    
    func testResetToDefaults() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        
        var customSettings = AppSettings()
        customSettings.visibleModuleIdentifiers = ["notes"]
        customSettings.enableHoverAffordance = false
        customSettings.notesMaxPinnedCount = 20
        
        store.update(settings: customSettings)
        XCTAssertEqual(store.settings, customSettings)
        
        store.resetToDefaults()
        XCTAssertEqual(store.settings, AppSettings())
        
        let reloadedStore = makeStore(storageURL: url)
        XCTAssertEqual(reloadedStore.settings, AppSettings())
        
        try? FileManager.default.removeItem(at: url)
    }
    
    func testPerDisplaySettings() {
        guard let screen = NSScreen.screens.first else {
            XCTFail("No screens available for testing per-display settings")
            return
        }
        
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        
        // Set active screen
        store.setActiveScreen(screen)
        
        // Modify top level properties
        var settings = store.settings
        settings.inactiveSurfaceWidth = 450.0
        settings.hoverSurfaceWidth = 580.0
        store.update(settings: settings)
        
        // Check active screen settings are stored
        let id = SettingsStore.screenIdentifier(screen)
        XCTAssertNotNil(store.settings.displaySettings[id])
        XCTAssertEqual(store.settings.displaySettings[id]?.inactiveSurfaceWidth, 450.0)
        XCTAssertEqual(store.settings.displaySettings[id]?.hoverSurfaceWidth, 580.0)
        
        // Reload and verify
        let reloadedStore = makeStore(storageURL: url)
        XCTAssertEqual(reloadedStore.settings.displaySettings[id]?.inactiveSurfaceWidth, 450.0)
        XCTAssertEqual(reloadedStore.settings.displaySettings[id]?.hoverSurfaceWidth, 580.0)
        
        try? FileManager.default.removeItem(at: url)
    }
}
