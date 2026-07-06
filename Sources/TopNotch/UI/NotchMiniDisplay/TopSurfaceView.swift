import SwiftUI
import Combine
import TopNotchCore

/// A SwiftUI view representing the top surface pill (virtual island or physical notch overlay).
/// Adapts its size and layout dynamically based on physical/virtual notch calibration sliders.
struct TopSurfaceView: View {
    /// The top safe area inset of the current display. If > 0, we assume the screen has a physical notch.
    let safeAreaTopInset: CGFloat
    
    /// Callback triggered when the pill is clicked.
    let onTap: () -> Void
    
    /// Tracks whether the mouse cursor is currently hovering over the pill.
    @State private var isHovered = false
    
    @ObservedObject private var stateStore = MusicStateStore.shared
    @ObservedObject private var settingsStore = SettingsStore.shared
    
    // Hover states for mini media buttons
    @State private var isHoveredPrevMini = false
    @State private var isHoveredPlayMini = false
    @State private var isHoveredNextMini = false
    
    @State private var elapsed: Double = 0.0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    /// Returns true if the target display screen has a physical notch.
    var hasNotch: Bool {
        if settingsStore.settings.forceVirtualIslandStyle {
            return false
        }
        return safeAreaTopInset > 0
    }
    
    /// Computes the target width of the pill based on notch presence, playback, and hover state.
    var targetWidth: CGFloat {
        let playing = stateStore.playbackState == .playing
        let hoverEnabled = settingsStore.settings.enableHoverAffordance
        let expansionEnabled = settingsStore.settings.enableLiveActivityExpansion
        let baseWidth = CGFloat(settingsStore.settings.customNotchWidth)
        
        if playing {
            return (isHovered && expansionEnabled) ? max(360, baseWidth + 160) : max(300, baseWidth + 100)
        }
        return (isHovered && hoverEnabled) ? max(300, baseWidth + 60) : baseWidth
    }
    
    /// Computes the target height of the pill based on notch presence, playback, and hover state.
    var targetHeight: CGFloat {
        let playing = stateStore.playbackState == .playing
        let hoverEnabled = settingsStore.settings.enableHoverAffordance
        let expansionEnabled = settingsStore.settings.enableLiveActivityExpansion
        let baseHeight = CGFloat(settingsStore.settings.customNotchHeight)
        
        if playing {
            let expanded = isHovered && expansionEnabled
            if hasNotch {
                return expanded ? baseHeight + 70 : baseHeight + 36
            } else {
                return expanded ? baseHeight + 60 : baseHeight + 32
            }
        } else {
            let expanded = isHovered && hoverEnabled
            if hasNotch {
                return expanded ? baseHeight + 24 : baseHeight
            } else {
                return expanded ? baseHeight + 20 : baseHeight
            }
        }
    }
    
    /// Computes the corner radius for the visual appearance.
    var targetCornerRadius: CGFloat {
        if hasNotch {
            return isHovered ? 22 : 18
        } else {
            return targetHeight / 2
        }
    }
    
    /// Top padding offset to align the pill centered in a 24pt menu bar for notchless screens.
    var topPadding: CGFloat {
        if hasNotch {
            return 0
        } else {
            return 1
        }
    }
    
    var body: some View {
        let playing = stateStore.playbackState == .playing
        VStack(spacing: 0) {
            Spacer().frame(height: topPadding)
            
            ZStack {
                surfaceShape
                    .fill(Color.black)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isHovered ? 0.07 : 0.035),
                                Color.clear,
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(surfaceShape)
                    )
                
                let expansionEnabled = settingsStore.settings.enableLiveActivityExpansion
                if playing {
                    if isHovered && expansionEnabled {
                        if let track = stateStore.currentTrack {
                            expandedNowPlaying(track)
                        }
                    } else {
                        if let track = stateStore.currentTrack {
                            compactNowPlaying(track)
                        } else {
                            compactIdleSurface(title: "Music")
                        }
                    }
                } else {
                    let hoverEnabled = settingsStore.settings.enableHoverAffordance
                    compactIdleSurface(title: (isHovered && hoverEnabled) ? "Top Notch" : "")
                }
            }
            .frame(width: targetWidth, height: targetHeight)
            .overlay(
                surfaceShape
                    .stroke(Color.white.opacity(isHovered ? 0.15 : 0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovered ? 0.4 : 0.15), radius: isHovered ? 8 : 3, y: isHovered ? 4 : 1.5)
            .animation(.spring(response: 0.28, dampingFraction: 0.75, blendDuration: 0), value: isHovered)
            .animation(.spring(response: 0.28, dampingFraction: 0.75, blendDuration: 0), value: stateStore.playbackState)
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                onTap()
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onReceive(timer) { _ in
            if stateStore.playbackState == .playing {
                self.elapsed = stateStore.playerPosition
            }
        }
    }
    
    private var surfaceShape: UnevenRoundedRectangle {
        if hasNotch {
            return UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: targetCornerRadius,
                    bottomTrailing: targetCornerRadius,
                    topTrailing: 0
                ),
                style: .continuous
            )
        }
        return UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: targetCornerRadius,
                bottomLeading: targetCornerRadius,
                bottomTrailing: targetCornerRadius,
                topTrailing: targetCornerRadius
            ),
            style: .continuous
        )
    }
    
    private func compactNowPlaying(_ track: NowPlayingTrack) -> some View {
        HStack(spacing: 8) {
            albumBadge(size: max(20, targetHeight - 8), cornerRadius: 6)
                .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(track.title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if case .synced(let lines) = stateStore.lyricsState, !lines.isEmpty {
                    let activeIndex = findActiveIndex(for: lines, time: elapsed)
                    Text(lines[activeIndex].text)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                } else {
                    Text(track.artist)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            equalizerIcon
                .scaleEffect(0.65)
                .padding(.trailing, 10)
        }
    }
    
    private func expandedNowPlaying(_ track: NowPlayingTrack) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                albumBadge(size: 32, cornerRadius: 6)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(track.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(track.artist)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                equalizerIcon
                    .scaleEffect(0.7)
            }
            
            if case .synced(let lines) = stateStore.lyricsState, !lines.isEmpty {
                let activeIndex = findActiveIndex(for: lines, time: elapsed)
                VStack(spacing: 1) {
                    Text(lines[activeIndex].text)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    if activeIndex < lines.count - 1 {
                        Text(lines[activeIndex + 1].text)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                    }
                }
                .frame(height: 22)
            } else {
                Spacer().frame(height: 22)
            }
            
            HStack(spacing: 12) {
                miniControlButton(systemName: "backward.fill", isHovered: isHoveredPrevMini) {
                    stateStore.previousTrack()
                }
                .onHover { isHoveredPrevMini = $0 }
                
                miniControlButton(
                    systemName: stateStore.playbackState == .playing ? "pause.fill" : "play.fill",
                    isHovered: isHoveredPlayMini
                ) {
                    stateStore.playpause()
                }
                .onHover { isHoveredPlayMini = $0 }
                
                miniControlButton(systemName: "forward.fill", isHovered: isHoveredNextMini) {
                    stateStore.nextTrack()
                }
                .onHover { isHoveredNextMini = $0 }
                
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
    }
    
    private func compactIdleSurface(title: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isHovered ? Color.green : Color.white.opacity(0.35))
                .frame(width: 6, height: 6)
            
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.88))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func albumBadge(size: CGFloat, cornerRadius: CGFloat) -> some View {
        Group {
            if let urlString = stateStore.currentTrack?.artworkUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderArtwork(size: size, cornerRadius: cornerRadius)
                }
            } else {
                placeholderArtwork(size: size, cornerRadius: cornerRadius)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
    }
    
    private func placeholderArtwork(size: CGFloat, cornerRadius: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.44, blue: 0.18),
                            Color(red: 0.18, green: 0.13, blue: 0.22),
                            Color(red: 0.06, green: 0.05, blue: 0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.36, weight: .semibold))
                        .foregroundColor(.white.opacity(0.86))
                )
        }
    }
    
    private var equalizerIcon: some View {
        HStack(alignment: .bottom, spacing: 4) {
            Capsule().frame(width: 4, height: 22)
            Capsule().frame(width: 4, height: 34)
            Capsule().frame(width: 4, height: 28)
        }
        .foregroundColor(Color(red: 0.76, green: 0.82, blue: 1.0))
        .shadow(color: Color(red: 0.45, green: 0.55, blue: 1.0).opacity(0.35), radius: 5)
    }
    
    private func miniControlButton(
        systemName: String,
        isHovered: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.white.opacity(isHovered ? 0.18 : 0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    private func findActiveIndex(for lines: [LyricsLine], time: Double) -> Int {
        var activeIndex = 0
        for (index, line) in lines.enumerated() {
            if line.timestamp <= time {
                activeIndex = index
            } else {
                break
            }
        }
        return activeIndex
    }
}
