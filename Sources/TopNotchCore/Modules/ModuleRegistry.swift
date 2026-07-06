import Foundation

/// Central registry for managing module layout order, visibility, and active vs. planned states.
@MainActor
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
        let visibleIds = SettingsStore.shared.settings.visibleModuleIdentifiers
        let activeMods = modules.filter { !$0.isPlannedOnly }
        let plannedMods = modules.filter { $0.isPlannedOnly }
        
        var orderedActive = [WorkflowModule]()
        for rawId in visibleIds {
            if let mod = activeMods.first(where: { $0.identifier.rawValue == rawId }) {
                var updated = mod
                updated.isVisible = true
                orderedActive.append(updated)
            }
        }
        for mod in activeMods {
            if !visibleIds.contains(mod.identifier.rawValue) {
                var updated = mod
                updated.isVisible = false
                orderedActive.append(updated)
            }
        }
        return orderedActive + plannedMods
    }
    
    /// Returns only modules that are active (not planned-only) and visible.
    public func getActiveVisibleModules() -> [WorkflowModule] {
        lock.lock()
        defer { lock.unlock() }
        let visibleIds = SettingsStore.shared.settings.visibleModuleIdentifiers
        let activeMods = modules.filter { !$0.isPlannedOnly }
        
        var result = [WorkflowModule]()
        for rawId in visibleIds {
            if let mod = activeMods.first(where: { $0.identifier.rawValue == rawId }) {
                var updated = mod
                updated.isVisible = true
                result.append(updated)
            }
        }
        return result
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
        
        var ids = SettingsStore.shared.settings.visibleModuleIdentifiers
        if let index = ids.firstIndex(of: identifier.rawValue) {
            ids.remove(at: index)
        } else {
            ids.append(identifier.rawValue)
        }
        
        var updated = SettingsStore.shared.settings
        updated.visibleModuleIdentifiers = ids
        SettingsStore.shared.update(settings: updated)
        SettingsStore.shared.save()
    }
    
    /// Sets the visibility of a given module type.
    public func setVisibility(for identifier: ModuleIdentifier, visible: Bool) {
        lock.lock()
        defer { lock.unlock() }
        if let index = modules.firstIndex(where: { $0.identifier == identifier }) {
            modules[index].isVisible = visible
        }
        
        var ids = SettingsStore.shared.settings.visibleModuleIdentifiers
        if visible {
            if !ids.contains(identifier.rawValue) {
                ids.append(identifier.rawValue)
            }
        } else {
            if let index = ids.firstIndex(of: identifier.rawValue) {
                ids.remove(at: index)
            }
        }
        
        var updated = SettingsStore.shared.settings
        updated.visibleModuleIdentifiers = ids
        SettingsStore.shared.update(settings: updated)
        SettingsStore.shared.save()
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
        
        let rawValues = newOrder
            .filter { !$0.isPlannedOnly && $0.isVisible }
            .map { $0.identifier.rawValue }
        
        var currentSettings = SettingsStore.shared.settings
        currentSettings.visibleModuleIdentifiers = rawValues
        SettingsStore.shared.update(settings: currentSettings)
        SettingsStore.shared.save()
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
