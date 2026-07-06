import Foundation

/// Central registry for managing module layout order, visibility, and active vs. planned states.
public final class ModuleRegistry: @unchecked Sendable {
    /// Shared registry instance.
    public static let shared = ModuleRegistry()
    
    private let lock = NSLock()
    private var modules: [WorkflowModule]
    
    private init() {
        self.modules = [
            // Active Modules (MVP)
            WorkflowModule(identifier: .music, name: "Music", iconName: "music.note", isPlannedOnly: false),
            WorkflowModule(identifier: .clipboard, name: "Clipboard", iconName: "doc.on.clipboard", isPlannedOnly: false),
            WorkflowModule(identifier: .notes, name: "Notes", iconName: "note.text", isPlannedOnly: false),
            
            // Planned Modules (Coming Soon)
            WorkflowModule(identifier: .calendar, name: "Calendar", iconName: "calendar", isPlannedOnly: true),
            WorkflowModule(identifier: .timer, name: "Timer", iconName: "timer", isPlannedOnly: true),
            WorkflowModule(identifier: .fileDrop, name: "File Drop", iconName: "square.and.arrow.down", isPlannedOnly: true),
            WorkflowModule(identifier: .quickCommands, name: "Commands", iconName: "terminal", isPlannedOnly: true),
            WorkflowModule(identifier: .agents, name: "Agents", iconName: "cpu", isPlannedOnly: true)
        ]
    }
    
    /// Returns the complete list of modules in their current registered order.
    public func getModules() -> [WorkflowModule] {
        lock.lock()
        defer { lock.unlock() }
        return modules
    }
    
    /// Returns only modules that are active (not planned-only) and visible.
    public func getActiveVisibleModules() -> [WorkflowModule] {
        lock.lock()
        defer { lock.unlock() }
        return modules.filter { !$0.isPlannedOnly && $0.isVisible }
    }
    
    /// Returns only planned modules that are visible.
    public func getPlannedVisibleModules() -> [WorkflowModule] {
        lock.lock()
        defer { lock.unlock() }
        return modules.filter { $0.isPlannedOnly && $0.isVisible }
    }
    
    /// Toggles the visibility state of a given module type.
    public func toggleVisibility(for identifier: ModuleIdentifier) {
        lock.lock()
        defer { lock.unlock() }
        if let index = modules.firstIndex(where: { $0.identifier == identifier }) {
            modules[index].isVisible.toggle()
        }
    }
    
    /// Sets the visibility of a given module type.
    public func setVisibility(for identifier: ModuleIdentifier, visible: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if let index = modules.firstIndex(where: { $0.identifier == identifier }) {
            modules[index].isVisible = visible
        }
    }
    
    /// Reorders the registry modules to match the ordering in the input array.
    public func updateModulesOrder(to newOrder: [WorkflowModule]) {
        lock.lock()
        defer { lock.unlock() }
        
        let orderedIds = newOrder.map { $0.identifier }
        var updated = [WorkflowModule]()
        
        // Add modules matching the new order
        for id in orderedIds {
            if let mod = modules.first(where: { $0.identifier == id }) {
                updated.append(mod)
            }
        }
        
        // Safeguard: Add any missing modules that weren't in newOrder to prevent data loss
        for mod in modules {
            if !orderedIds.contains(mod.identifier) {
                updated.append(mod)
            }
        }
        
        self.modules = updated
    }
    
    /// Resets the registry state back to default configuration values (useful for tests).
    public func resetToDefaults() {
        lock.lock()
        defer { lock.unlock() }
        self.modules = [
            WorkflowModule(identifier: .music, name: "Music", iconName: "music.note", isPlannedOnly: false),
            WorkflowModule(identifier: .clipboard, name: "Clipboard", iconName: "doc.on.clipboard", isPlannedOnly: false),
            WorkflowModule(identifier: .notes, name: "Notes", iconName: "note.text", isPlannedOnly: false),
            WorkflowModule(identifier: .calendar, name: "Calendar", iconName: "calendar", isPlannedOnly: true),
            WorkflowModule(identifier: .timer, name: "Timer", iconName: "timer", isPlannedOnly: true),
            WorkflowModule(identifier: .fileDrop, name: "File Drop", iconName: "square.and.arrow.down", isPlannedOnly: true),
            WorkflowModule(identifier: .quickCommands, name: "Commands", iconName: "terminal", isPlannedOnly: true),
            WorkflowModule(identifier: .agents, name: "Agents", iconName: "cpu", isPlannedOnly: true)
        ]
    }
}
