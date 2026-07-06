import SwiftUI
import TopNotchCore

/// The root SwiftUI view for the floating main panel dropdown dashboard,
/// implementing the custom 3-column layout, flared top edges, and bottom U-tab lyrics.
struct MainPanelView: View {
    /// Callback to trigger opening the settings window.
    let onOpenSettings: () -> Void
    
    @ObservedObject private var musicStore = MusicStateStore.shared
    @ObservedObject private var settingsStore = SettingsStore.shared
    
    @State private var leftTab: LeftTab = .overview
    @State private var rightTab: RightTab = .agents
    
    var body: some View {
        let hasNotch = settingsStore.settings.forceVirtualIslandStyle ? false : (NSScreen.main?.safeAreaInsets.top ?? 0 > 0)
        let notchWidth = CGFloat(settingsStore.settings.customNotchWidth)
        let notchHeight = CGFloat(settingsStore.settings.customNotchHeight)
        
        VStack(spacing: 0) {
            // Top Navigation Bar (anchored to top wing areas)
            HStack {
                // Left Wing Tabs
                HStack(spacing: 8) {
                    CapsuleLabel(title: "Overview", isSelected: leftTab == .overview) {
                        leftTab = .overview
                    }
                    CapsuleLabel(title: "Media", isSelected: leftTab == .media) {
                        leftTab = .media
                    }
                }
                .frame(width: 180, alignment: .leading)
                
                Spacer()
                
                // Notch Spacer (so text/tabs do not overlap the notch)
                Spacer()
                    .frame(width: notchWidth + 40)
                
                Spacer()
                
                // Right Wing Tabs + Settings Button
                HStack(spacing: 8) {
                    CapsuleLabel(title: "Agents", isSelected: rightTab == .agents) {
                        rightTab = .agents
                    }
                    CapsuleLabel(title: "Tools", isSelected: rightTab == .tools) {
                        rightTab = .tools
                    }
                    
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 26, height: 26)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
                .frame(width: 220, alignment: .trailing)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .frame(height: 38)
            
            // 3-Column Content Layout
            HStack(alignment: .top, spacing: 14) {
                // Left Column (Calendar Widget)
                Group {
                    if leftTab == .overview {
                        NotchCalendarView()
                    } else {
                        VStack {
                            Text("Media Center")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                    }
                }
                .frame(width: 248)
                
                // Center Column (Media Player)
                NotchMediaPlayerColumn(elapsed: $musicStore.playerPosition)
                    .frame(width: 270)
                
                // Right Column (Clipboard Widget)
                Group {
                    if rightTab == .agents {
                        ClipboardPanelView()
                    } else {
                        VStack(spacing: 12) {
                            Text("Tools List")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text("Clipboard, Window manager, and system status widgets.")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(12)
                    }
                }
                .frame(width: 248)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .frame(height: 162)
            
            Spacer()
            
            // Bottom Lyrics Area (centered inside the U-shape tab)
            NotchLyricsView(elapsed: musicStore.playerPosition)
                .frame(width: 360, height: 48)
                .padding(.bottom, 2)
        }
        .frame(width: 840, height: 260)
        .background(
            ZStack {
                Color.black
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .clipShape(NotchPanelShape(
            safeAreaTopInset: NSScreen.main?.safeAreaInsets.top ?? 0,
            hasNotch: hasNotch,
            notchWidth: notchWidth,
            notchHeight: notchHeight
        ))
        .overlay(
            NotchPanelShape(
                safeAreaTopInset: NSScreen.main?.safeAreaInsets.top ?? 0,
                hasNotch: hasNotch,
                notchWidth: notchWidth,
                notchHeight: notchHeight
            )
            .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private enum LeftTab {
    case overview
    case media
}

private enum RightTab {
    case agents
    case tools
}

private struct CapsuleLabel: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(isSelected ? 0.95 : 0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(isSelected ? 0.12 : 0.0))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
