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
        }
        .padding(20)
        .frame(width: 480, height: 300)
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
}
