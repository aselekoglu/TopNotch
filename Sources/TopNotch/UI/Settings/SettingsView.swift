import SwiftUI
import AppKit
import TopNotchCore

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @State private var activeTab = 0
    
    var body: some View {
        TabView(selection: $activeTab) {
            interactionView
                .tabItem {
                    Label("Interaction", systemImage: "hand.point.up.left.fill")
                }
                .tag(0)
            
            displayView
                .tabItem {
                    Label("Display", systemImage: "display")
                }
                .tag(1)
            
            modulesView
                .tabItem {
                    Label("Modules", systemImage: "square.grid.2x2.fill")
                }
                .tag(2)
        }
        .padding(20)
        .frame(width: 480, height: 350)
    }
    
    private var interactionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interaction Preferences")
                .font(.headline)
            
            Toggle("Enable Hover Spring Scale Animation", isOn: Binding(
                get: { store.settings.enableHoverAffordance },
                set: { newValue in
                    var updated = store.settings
                    updated.enableHoverAffordance = newValue
                    store.update(settings: updated)
                }
            ))
            
            Toggle("Expand Notch to Show Music Controls on Hover", isOn: Binding(
                get: { store.settings.enableLiveActivityExpansion },
                set: { newValue in
                    var updated = store.settings
                    updated.enableLiveActivityExpansion = newValue
                    store.update(settings: updated)
                }
            ))
            
            Divider()
            
            HStack {
                Text("Global Keyboard Shortcut")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("⌥ Space")
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
            }
        }
    }
    
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Display Preferences")
                .font(.headline)
            
            Toggle("Force Virtual Island (Notchless) Style", isOn: Binding(
                get: { store.settings.forceVirtualIslandStyle },
                set: { newValue in
                    var updated = store.settings
                    updated.forceVirtualIslandStyle = newValue
                    store.update(settings: updated)
                }
            ))
            
            Picker("Target Display", selection: Binding(
                get: { store.settings.targetDisplayIndex },
                set: { newValue in
                    var updated = store.settings
                    updated.targetDisplayIndex = newValue
                    store.update(settings: updated)
                }
            )) {
                ForEach(0..<NSScreen.screens.count, id: \.self) { index in
                    Text("Display \(index + 1) (\(Int(NSScreen.screens[index].frame.width))x\(Int(NSScreen.screens[index].frame.height)))")
                        .tag(index)
                }
            }
            .pickerStyle(.menu)
            
            Text("Determines where the Top Notch overlay and dropdown main panel appear on launch.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var modulesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Active Modules")
                    .font(.headline)
                
                let activeModules = ModuleRegistry.shared.getModules().filter { !$0.isPlannedOnly }
                VStack(spacing: 8) {
                    ForEach(Array(activeModules.enumerated()), id: \.element.identifier) { index, module in
                        HStack(spacing: 12) {
                            Image(systemName: module.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .frame(width: 24, height: 24)
                                .background(Color.primary.opacity(0.1))
                                .cornerRadius(6)
                            
                            Text(module.name)
                                .font(.body)
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: {
                                    store.settings.visibleModuleIdentifiers.contains(module.identifier.rawValue)
                                },
                                set: { isVisible in
                                    ModuleRegistry.shared.setVisibility(for: module.identifier, visible: isVisible)
                                }
                            ))
                            .labelsHidden()
                            
                            Button(action: {
                                moveModule(index: index, direction: -1)
                            }) {
                                Text("▲")
                            }
                            .disabled(index == 0)
                            
                            Button(action: {
                                moveModule(index: index, direction: 1)
                            }) {
                                Text("▼")
                            }
                            .disabled(index == activeModules.count - 1)
                        }
                    }
                }
                
                Divider()
                
                Text("Planned Modules")
                    .font(.headline)
                
                let plannedModules = ModuleRegistry.shared.getModules().filter { $0.isPlannedOnly }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plannedModules, id: \.identifier) { module in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 12) {
                                Image(systemName: module.iconName)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, height: 24)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(6)
                                
                                Text(module.name)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("Coming Soon")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(4)
                                    .foregroundColor(.secondary)
                            }
                            if module.identifier == .agents {
                                Text("Phase 2 - Read-Only preview. No active execution.")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 36)
                            }
                        }
                    }
                }
            }
            .padding(.trailing, 8) // prevent horizontal scrollbar overlap
        }
    }
    
    private func moveModule(index: Int, direction: Int) {
        var activeModules = ModuleRegistry.shared.getModules().filter { !$0.isPlannedOnly }
        let targetIndex = index + direction
        guard targetIndex >= 0 && targetIndex < activeModules.count else { return }
        
        activeModules.swapAt(index, targetIndex)
        ModuleRegistry.shared.updateModulesOrder(to: activeModules)
    }
}
