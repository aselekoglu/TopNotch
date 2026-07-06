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
        
        store.update(settings: newSettings)
        
        let reloadedStore = makeStore(storageURL: url)
        XCTAssertEqual(reloadedStore.settings, newSettings)
        
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
}
