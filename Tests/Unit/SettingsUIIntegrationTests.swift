import XCTest
import SwiftUI
import Combine
@testable import TopNotchCore

@MainActor
final class SettingsUIIntegrationTests: XCTestCase {
    
    private var store: SettingsStore {
        SettingsStore.shared
    }
    
    override func setUp() async throws {
        try await super.setUp()
        store.resetToDefaults()
    }
    
    override func tearDown() async throws {
        store.resetToDefaults()
        try await super.tearDown()
    }
    
    func testSettingsViewInitializationAndBindings() {
        // Instantiate SettingsView to ensure it renders/compiles
        let view = SettingsView()
        XCTAssertNotNil(view)
        
        // Verify default settings values
        XCTAssertTrue(store.settings.enableHoverAffordance)
        XCTAssertTrue(store.settings.enableLiveActivityExpansion)
        XCTAssertFalse(store.settings.forceVirtualIslandStyle)
        XCTAssertEqual(store.settings.targetDisplayIndex, 0)
        
        // Simulating interaction by updating settings via the store,
        // which the SettingsView binds to
        var updated = store.settings
        updated.enableHoverAffordance = false
        updated.enableLiveActivityExpansion = false
        updated.forceVirtualIslandStyle = true
        updated.targetDisplayIndex = 1
        
        store.update(settings: updated)
        
        // Verify changes are updated in the store
        XCTAssertFalse(store.settings.enableHoverAffordance)
        XCTAssertFalse(store.settings.enableLiveActivityExpansion)
        XCTAssertTrue(store.settings.forceVirtualIslandStyle)
        XCTAssertEqual(store.settings.targetDisplayIndex, 1)
    }
}
