import XCTest
@testable import TopNotchCore

@MainActor
final class ModuleSettingsIntegrationTests: XCTestCase {
    
    override func setUp() async throws {
        try await super.setUp()
        // Reset settings store and module registry to default states
        SettingsStore.shared.resetToDefaults()
        ModuleRegistry.shared.resetToDefaults()
    }
    
    override func tearDown() async throws {
        // Clean up
        SettingsStore.shared.resetToDefaults()
        ModuleRegistry.shared.resetToDefaults()
        try await super.tearDown()
    }
    
    func testToggleActiveModuleVisibilityUpdatesSettings() {
        let registry = ModuleRegistry.shared
        
        // Initial state check
        XCTAssertEqual(SettingsStore.shared.settings.visibleModuleIdentifiers, ["music", "clipboard", "notes"])
        
        // Toggle music (hide it)
        registry.toggleVisibility(for: .music)
        
        // Verify music is removed from SettingsStore visibleModuleIdentifiers
        XCTAssertEqual(SettingsStore.shared.settings.visibleModuleIdentifiers, ["clipboard", "notes"])
        
        // Toggle music back (show it)
        registry.toggleVisibility(for: .music)
        
        // Verify music is restored/appended to SettingsStore visibleModuleIdentifiers
        XCTAssertTrue(SettingsStore.shared.settings.visibleModuleIdentifiers.contains("music"))
    }
    
    func testSetVisibilityUpdatesSettings() {
        let registry = ModuleRegistry.shared
        
        // Set clipboard to invisible
        registry.setVisibility(for: .clipboard, visible: false)
        XCTAssertEqual(SettingsStore.shared.settings.visibleModuleIdentifiers, ["music", "notes"])
        
        // Set clipboard back to visible
        registry.setVisibility(for: .clipboard, visible: true)
        XCTAssertTrue(SettingsStore.shared.settings.visibleModuleIdentifiers.contains("clipboard"))
    }
    
    func testReorderingActiveModulesUpdatesSettings() {
        let registry = ModuleRegistry.shared
        
        // Get initial ordered active modules
        let activeModules = registry.getModules().filter { !$0.isPlannedOnly }
        XCTAssertEqual(activeModules.count, 3)
        XCTAssertEqual(activeModules[0].identifier, .music)
        XCTAssertEqual(activeModules[1].identifier, .clipboard)
        XCTAssertEqual(activeModules[2].identifier, .notes)
        
        // Swap Music (index 0) and Clipboard (index 1)
        var rearranged = activeModules
        rearranged.swapAt(0, 1)
        
        // Update order in registry
        registry.updateModulesOrder(to: rearranged)
        
        // Verify SettingsStore visibleModuleIdentifiers is updated to match new order
        XCTAssertEqual(SettingsStore.shared.settings.visibleModuleIdentifiers, ["clipboard", "music", "notes"])
        
        // Verify that getActiveVisibleModules() returns in the correct reordered order
        let activeVisible = registry.getActiveVisibleModules()
        XCTAssertEqual(activeVisible.count, 3)
        XCTAssertEqual(activeVisible[0].identifier, .clipboard)
        XCTAssertEqual(activeVisible[1].identifier, .music)
        XCTAssertEqual(activeVisible[2].identifier, .notes)
    }
}
