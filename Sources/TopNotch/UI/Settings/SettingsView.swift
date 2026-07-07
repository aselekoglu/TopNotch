import SwiftUI
import AppKit
import TopNotchCore

struct SettingsView: View {
    @ObservedObject private var store = SettingsStore.shared
    @ObservedObject private var highlightStore = NotchCalibrationHighlightStore.shared
    @State private var activeTab = 0
    
    private var displayPickerBinding: Binding<Int> {
        Binding(
            get: {
                if let active = store.activeScreen {
                    let activeId = SettingsStore.screenIdentifier(active)
                    return NSScreen.screens.firstIndex { SettingsStore.screenIdentifier($0) == activeId } ?? 0
                }
                return 0
            },
            set: { index in
                if index >= 0 && index < NSScreen.screens.count {
                    store.setActiveScreen(NSScreen.screens[index])
                }
            }
        )
    }
    
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
        .frame(minWidth: 520, maxWidth: .infinity, minHeight: 560, maxHeight: .infinity)
    }
    
    private var interactionView: some View {
        ScrollView(.vertical, showsIndicators: true) {
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
            .padding(.trailing, 8)
        }
    }
    
    private var displayView: some View {
        ScrollView(.vertical, showsIndicators: true) {
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
                
                Divider()

                Text("Idle Hover Display")
                    .font(.headline)

                Picker("Widget Type", selection: Binding(
                    get: { store.settings.idleWidgetType },
                    set: { newValue in
                        var updated = store.settings
                        updated.idleWidgetType = newValue
                        store.update(settings: updated)
                    }
                )) {
                    Text("None").tag("none")
                    Text("System Resources (CPU & RAM)").tag("systemResources")
                    Text("Companion Sprite (Retro Pet)").tag("retroSprite")
                    Text("Simulated Weather").tag("weather")
                }
                .pickerStyle(.menu)

                if store.settings.idleWidgetType == "retroSprite" {
                    Picker("Select Companion", selection: Binding(
                        get: { store.settings.selectedSpriteType },
                        set: { newValue in
                            var updated = store.settings
                            updated.selectedSpriteType = newValue
                            store.update(settings: updated)
                        }
                    )) {
                        Text("Pixel Cat").tag("cat")
                        Text("Pac-Man Ghost").tag("ghost")
                        Text("Glowing Star").tag("star")
                    }
                    .pickerStyle(.menu)
                }

                Divider()

                Text("Calibration & Screen Sizing")
                    .font(.headline)

                Picker("Configure Screen", selection: displayPickerBinding) {
                    ForEach(0..<NSScreen.screens.count, id: \.self) { index in
                        let screen = NSScreen.screens[index]
                        let name = screen.localizedName.isEmpty ? "Display" : screen.localizedName
                        Text("\(name) (\(Int(screen.frame.width))x\(Int(screen.frame.height)))")
                            .tag(index)
                    }
                }
                .pickerStyle(.menu)

                calibrationPreview

                settingsGroup(
                    title: "Physical Notch Deadzone",
                    region: .physicalDeadzone,
                    width: settingsBinding(\.customNotchWidth, region: .physicalDeadzone, axis: .width),
                    height: settingsBinding(\.customNotchHeight, region: .physicalDeadzone, axis: .height),
                    widthRange: 40...420,
                    heightRange: 0...96
                )

                settingsGroup(
                    title: "Inactive View Size",
                    region: .inactiveSurface,
                    width: settingsBinding(\.inactiveSurfaceWidth, region: .inactiveSurface, axis: .width),
                    height: settingsBinding(\.inactiveSurfaceHeight, region: .inactiveSurface, axis: .height),
                    widthRange: 220...760,
                    heightRange: 34...150
                )

                settingsGroup(
                    title: "Hover View Size",
                    region: .hoverSurface,
                    width: settingsBinding(\.hoverSurfaceWidth, region: .hoverSurface, axis: .width),
                    height: settingsBinding(\.hoverSurfaceHeight, region: .hoverSurface, axis: .height),
                    widthRange: 280...900,
                    heightRange: 56...240
                )
            }
            .padding(.trailing, 8)
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
            .padding(.trailing, 8)
        }
    }
    
    private func moveModule(index: Int, direction: Int) {
        var activeModules = ModuleRegistry.shared.getModules().filter { !$0.isPlannedOnly }
        let targetIndex = index + direction
        guard targetIndex >= 0 && targetIndex < activeModules.count else { return }
        
        activeModules.swapAt(index, targetIndex)
        ModuleRegistry.shared.updateModulesOrder(to: activeModules)
    }

    private func settingsGroup(
        title: String,
        region: NotchCalibrationRegion,
        width: Binding<Double>,
        height: Binding<Double>,
        widthRange: ClosedRange<Double>,
        heightRange: ClosedRange<Double>
    ) -> some View {
        let isActive = highlightStore.activeHighlight?.region == region
        let hasPhysicalNotch = Binding<Bool>(
            get: {
                if region == .physicalDeadzone {
                    return store.settings.customNotchHeight > 0
                }
                return true
            },
            set: { hasNotch in
                if region == .physicalDeadzone {
                    var updated = store.settings
                    if hasNotch {
                        updated.customNotchWidth = 180.0
                        updated.customNotchHeight = 24.0
                    } else {
                        updated.customNotchWidth = 0.0
                        updated.customNotchHeight = 0.0
                    }
                    store.update(settings: updated)
                }
            }
        )

        return GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if region == .physicalDeadzone {
                    Toggle("Has Physical Notch", isOn: hasPhysicalNotch)
                        .toggleStyle(.checkbox)
                        .padding(.bottom, 4)
                }

                if region != .physicalDeadzone || hasPhysicalNotch.wrappedValue {
                    settingSliderRow(
                        label: "Width",
                        region: region,
                        axis: .width,
                        value: width,
                        range: widthRange
                    )

                    settingSliderRow(
                        label: "Height",
                        region: region,
                        axis: .height,
                        value: height,
                        range: heightRange
                    )
                } else {
                    Text("No physical notch active for this screen. The active zone floats as a virtual island below the menu bar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.top, 4)
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(calibrationColor(for: region).opacity(isActive ? 0.08 : 0.0))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(calibrationColor(for: region).opacity(isActive ? 0.4 : 0.0), lineWidth: 1)
        )
    }

    private func settingSliderRow(
        label: String,
        region: NotchCalibrationRegion,
        axis: NotchCalibrationAxis,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        let isActive = highlightStore.activeHighlight == NotchCalibrationHighlight(region: region, axis: axis)
        return HStack(spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(isActive ? calibrationColor(for: region) : .primary)
                .frame(width: 52, alignment: .leading)

            GlassSlider(
                value: value,
                range: range,
                accentColor: calibrationColor(for: region),
                onEditingChanged: { isEditing in
                    if isEditing {
                        highlightStore.activate(region: region, axis: axis)
                    }
                }
            )

            Text("\(Int(value.wrappedValue)) pt")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(isActive ? calibrationColor(for: region) : .secondary)
                .frame(width: 54, alignment: .trailing)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(calibrationColor(for: region).opacity(isActive ? 0.12 : 0.0))
        )
    }

    private var calibrationPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calibration Preview")
                .font(.subheadline.weight(.semibold))

            GeometryReader { proxy in
                let settings = store.settings
                let inactiveWidth = CGFloat(settings.inactiveSurfaceWidth)
                let inactiveHeight = CGFloat(settings.inactiveSurfaceHeight)
                let hoverWidth = CGFloat(settings.hoverSurfaceWidth)
                let hoverHeight = CGFloat(settings.hoverSurfaceHeight)
                let deadzoneWidth = CGFloat(settings.customNotchWidth)
                let deadzoneHeight = CGFloat(settings.customNotchHeight)
                let maxSurfaceWidth = max(hoverWidth, inactiveWidth, deadzoneWidth, 1)
                let maxSurfaceHeight = max(hoverHeight, inactiveHeight, deadzoneHeight, 1)
                let scale = min((proxy.size.width - 24) / maxSurfaceWidth, (proxy.size.height - 18) / maxSurfaceHeight)
                let inactiveSize = CGSize(
                    width: inactiveWidth * scale,
                    height: inactiveHeight * scale
                )
                let hoverSize = CGSize(
                    width: hoverWidth * scale,
                    height: hoverHeight * scale
                )
                let deadzoneSize = CGSize(
                    width: deadzoneWidth * scale,
                    height: max(2, deadzoneHeight * scale)
                )

                ZStack(alignment: .top) {
                    calibrationShape(size: hoverSize, region: .hoverSurface)
                    calibrationShape(size: inactiveSize, region: .inactiveSurface)

                    if deadzoneHeight > 0 {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(calibrationColor(for: .physicalDeadzone).opacity(activeOpacity(for: .physicalDeadzone, fill: true)))
                            .frame(width: deadzoneSize.width, height: deadzoneSize.height)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(calibrationColor(for: .physicalDeadzone).opacity(activeOpacity(for: .physicalDeadzone, fill: false)), lineWidth: 2)
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 6)
            }
            .frame(height: 92)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    private func calibrationShape(size: CGSize, region: NotchCalibrationRegion) -> some View {
        RoundedRectangle(cornerRadius: max(8, min(size.height / 3, 22)), style: .continuous)
            .fill(calibrationColor(for: region).opacity(activeOpacity(for: region, fill: true)))
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: max(8, min(size.height / 3, 22)), style: .continuous)
                    .stroke(calibrationColor(for: region).opacity(activeOpacity(for: region, fill: false)), lineWidth: 2)
            )
    }

    private func activeOpacity(for region: NotchCalibrationRegion, fill: Bool) -> Double {
        let isActive = highlightStore.activeHighlight?.region == region
        if isActive {
            return fill ? 0.24 : 0.92
        }
        return fill ? 0.07 : 0.28
    }

    private func calibrationColor(for region: NotchCalibrationRegion) -> Color {
        switch region {
        case .physicalDeadzone:
            return Color(red: 0.35, green: 0.67, blue: 1.0)
        case .inactiveSurface:
            return Color(red: 0.42, green: 0.86, blue: 0.58)
        case .hoverSurface:
            return Color(red: 1.0, green: 0.62, blue: 0.32)
        }
    }

    private func settingsBinding(
        _ keyPath: WritableKeyPath<AppSettings, Double>,
        region: NotchCalibrationRegion,
        axis: NotchCalibrationAxis
    ) -> Binding<Double> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { value in
                highlightStore.activate(region: region, axis: axis)
                var updated = store.settings
                updated[keyPath: keyPath] = value
                store.update(settings: updated)
            }
        )
    }
}

struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let accentColor: Color
    let onEditingChanged: (Bool) -> Void
    
    @State private var isDragging = false
    @State private var isHovered = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let percent = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
            let fillWidth = max(0, min(width, width * percent))
            
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .frame(height: 8)
                
                // Active Track
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.4), accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: fillWidth, height: 8)
                    .shadow(color: accentColor.opacity(0.3), radius: isDragging ? 6 : 2)
                
                // Frosted Thumb
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 3, x: 0, y: 1.5)
                    .frame(width: 16, height: 16)
                    .scaleEffect(isDragging ? 1.3 : (isHovered ? 1.15 : 1.0))
                    .offset(x: max(0, min(width - 16, fillWidth - 8)))
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isDragging || isHovered)
            }
            .frame(height: 16)
            .contentShape(Rectangle())
            .onHover { hovering in
                isHovered = hovering
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        onEditingChanged(true)
                        let locationX = gesture.location.x
                        let newPercent = max(0, min(1, locationX / width))
                        let newValue = range.lowerBound + Double(newPercent) * (range.upperBound - range.lowerBound)
                        value = newValue.rounded()
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged(false)
                    }
            )
        }
        .frame(height: 16)
    }
}
