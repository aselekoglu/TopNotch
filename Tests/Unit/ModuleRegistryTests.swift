import XCTest
@testable import TopNotchCore

final class ModuleRegistryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        ModuleRegistry.shared.resetToDefaults()
    }
    
    override func tearDown() {
        ModuleRegistry.shared.resetToDefaults()
        super.tearDown()
    }
    
    func testDefaultModulesState() {
        let registry = ModuleRegistry.shared
        let allModules = registry.getModules()
        
        // Verify total default count
        XCTAssertEqual(allModules.count, 8)
        
        let activeModules = allModules.filter { !$0.isPlannedOnly }
        let plannedModules = allModules.filter { $0.isPlannedOnly }
        
        XCTAssertEqual(activeModules.count, 3)
        XCTAssertEqual(plannedModules.count, 5)
        
        // Verify default order
        XCTAssertEqual(allModules[0].identifier, .music)
        XCTAssertEqual(allModules[1].identifier, .clipboard)
        XCTAssertEqual(allModules[2].identifier, .notes)
    }
    
    func testToggleVisibility() {
        let registry = ModuleRegistry.shared
        
        // Ensure default is true
        XCTAssertTrue(registry.getModules().first(where: { $0.identifier == .music })?.isVisible ?? false)
        
        // Toggle visibility to hide it
        registry.toggleVisibility(for: .music)
        XCTAssertFalse(registry.getModules().first(where: { $0.identifier == .music })?.isVisible ?? true)
        
        // Verify filtered lists exclude it
        let activeVisible = registry.getActiveVisibleModules()
        XCTAssertFalse(activeVisible.contains(where: { $0.identifier == .music }))
        XCTAssertEqual(activeVisible.count, 2)
    }
    
    func testSetVisibility() {
        let registry = ModuleRegistry.shared
        
        // Set visibility directly
        registry.setVisibility(for: .calendar, visible: false)
        let plannedVisible = registry.getPlannedVisibleModules()
        XCTAssertFalse(plannedVisible.contains(where: { $0.identifier == .calendar }))
    }
    
    func testUpdateModulesOrder() {
        let registry = ModuleRegistry.shared
        let originalOrder = registry.getModules()
        
        // Shuffle order: notes, clipboard, music
        let rearranged = [
            originalOrder[2], // notes
            originalOrder[1], // clipboard
            originalOrder[0]  // music
        ]
        
        registry.updateModulesOrder(to: rearranged)
        let newOrder = registry.getModules()
        
        // Verify order changed
        XCTAssertEqual(newOrder[0].identifier, .notes)
        XCTAssertEqual(newOrder[1].identifier, .clipboard)
        XCTAssertEqual(newOrder[2].identifier, .music)
        
        // Ensure safeguard kept planned modules intact at the end
        XCTAssertEqual(newOrder.count, 8)
        XCTAssertEqual(newOrder[3].identifier, .calendar)
    }
}
