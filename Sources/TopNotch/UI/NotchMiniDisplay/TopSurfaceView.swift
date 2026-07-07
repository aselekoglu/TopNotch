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
    @ObservedObject private var highlightStore = NotchCalibrationHighlightStore.shared
    
    // Hover states for mini media buttons
    @State private var isHoveredPrevMini = false
    @State private var isHoveredPlayMini = false
    @State private var isHoveredNextMini = false
    
    @State private var elapsed: Double = 0.0
    @State private var currentTimeString = ""
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    /// Returns true if the target display screen has a physical notch.
    var hasNotch: Bool {
        if settingsStore.settings.forceVirtualIslandStyle {
            return false
        }
        return safeAreaTopInset > 0
    }

    private var isHoverExpansionActive: Bool {
        let settings = settingsStore.settings
        if stateStore.playbackState == .playing {
            return isHovered && settings.enableLiveActivityExpansion
        }
        return isHovered && settings.enableHoverAffordance
    }

    private var inactiveSurfaceSize: CGSize {
        CGSize(
            width: CGFloat(settingsStore.settings.inactiveSurfaceWidth),
            height: CGFloat(settingsStore.settings.inactiveSurfaceHeight)
        )
    }

    private var hoverSurfaceSize: CGSize {
        CGSize(
            width: CGFloat(settingsStore.settings.hoverSurfaceWidth),
            height: CGFloat(settingsStore.settings.hoverSurfaceHeight)
        )
    }

    private var physicalDeadzoneSize: CGSize {
        CGSize(
            width: CGFloat(settingsStore.settings.customNotchWidth),
            height: CGFloat(settingsStore.settings.customNotchHeight)
        )
    }

    private var notchContentLayout: TopSurfaceContentLayout {
        NotchGeometryCalculator.calculateTopSurfaceContentLayout(
            surfaceSize: CGSize(width: targetWidth, height: targetHeight),
            deadzoneWidth: physicalDeadzoneSize.width,
            deadzoneHeight: physicalDeadzoneSize.height
        )
    }
    
    /// Computes the target width of the pill based on notch presence, playback, and hover state.
    var targetWidth: CGFloat {
        let size = isHoverExpansionActive ? hoverSurfaceSize : inactiveSurfaceSize
        return size.width
    }
    
    /// Computes the target height of the pill based on notch presence, playback, and hover state.
    var targetHeight: CGFloat {
        let size = isHoverExpansionActive ? hoverSurfaceSize : inactiveSurfaceSize
        return size.height
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
                            if hasNotch {
                                expandedNowPlayingWithDeadzone(track)
                            } else {
                                expandedNowPlaying(track)
                            }
                        }
                    } else {
                        if let track = stateStore.currentTrack {
                            if hasNotch {
                                compactNowPlayingWithDeadzone(track)
                            } else {
                                compactNowPlaying(track)
                            }
                        } else {
                            if hasNotch {
                                compactIdleSurfaceWithDeadzone(title: "Music")
                            } else {
                                compactIdleSurface(title: "Music")
                            }
                        }
                    }
                } else {
                    if isHoverExpansionActive {
                        expandedIdleSurface()
                    } else {
                        if hasNotch {
                            compactIdleSurfaceWithDeadzone(title: "")
                        } else {
                            compactIdleSurface(title: "")
                        }
                    }
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
        .overlay(alignment: .top) {
            calibrationHighlightOverlay
                .padding(.top, topPadding)
        }
        .onReceive(timer) { _ in
            if stateStore.playbackState == .playing {
                self.elapsed = stateStore.playerPosition
            }
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self.currentTimeString = formatter.string(from: Date())
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self.currentTimeString = formatter.string(from: Date())
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

    private func compactNowPlayingWithDeadzone(_ track: NowPlayingTrack) -> some View {
        VStack(spacing: 0) {
            deadzoneTopBand(
                leading: {
                    albumBadge(
                        size: max(22, min(notchContentLayout.leadingBandFrame.height, physicalDeadzoneSize.height)),
                        cornerRadius: 6
                    )
                },
                trailing: {
                    equalizerIcon
                        .scaleEffect(0.58, anchor: .trailing)
                }
            )

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
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

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

    private func expandedNowPlayingWithDeadzone(_ track: NowPlayingTrack) -> some View {
        VStack(spacing: 0) {
            deadzoneTopBand(
                leading: {
                    albumBadge(size: 28, cornerRadius: 6)
                },
                trailing: {
                    equalizerIcon
                        .scaleEffect(0.62, anchor: .trailing)
                }
            )

            VStack(spacing: 6) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(track.artist)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 10) {
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
                    }
                }

                Group {
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
                    } else {
                        Text(track.album)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.45))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 22, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
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

    private func compactIdleSurfaceWithDeadzone(title: String) -> some View {
        VStack(spacing: 0) {
            deadzoneTopBand(
                leading: {
                    Circle()
                        .fill(isHovered ? Color.green : Color.white.opacity(0.35))
                        .frame(width: 6, height: 6)
                },
                trailing: {
                    Color.clear.frame(width: 12, height: 12)
                }
            )

            HStack(spacing: 8) {
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.88))
                        .lineLimit(1)
                } else {
                    Text(" ")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .hidden()
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private func deadzoneTopBand<Leading: View, Trailing: View>(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            HStack {
                leading()
                Spacer(minLength: 0)
            }
            .frame(width: notchContentLayout.leadingBandFrame.width, alignment: .leading)
            .clipped()

            Spacer(minLength: notchContentLayout.deadzoneFrame.width)

            HStack {
                Spacer(minLength: 0)
                trailing()
            }
            .frame(width: notchContentLayout.trailingBandFrame.width, alignment: .trailing)
            .clipped()
        }
        .frame(height: max(0, notchContentLayout.deadzoneFrame.height))
        .padding(.horizontal, 10)
        .padding(.top, 6)
    }

    @ViewBuilder
    private var calibrationHighlightOverlay: some View {
        if let activeHighlight = highlightStore.activeHighlight {
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    switch activeHighlight.region {
                    case .physicalDeadzone:
                        calibrationRectangle(
                            size: physicalDeadzoneSize,
                            color: calibrationColor(for: .physicalDeadzone),
                            cornerRadius: 8
                        )
                    case .inactiveSurface:
                        calibrationRectangle(
                            size: inactiveSurfaceSize,
                            color: calibrationColor(for: .inactiveSurface),
                            cornerRadius: min(24, inactiveSurfaceSize.height / 2)
                        )
                    case .hoverSurface:
                        calibrationRectangle(
                            size: hoverSurfaceSize,
                            color: calibrationColor(for: .hoverSurface),
                            cornerRadius: min(24, hoverSurfaceSize.height / 2)
                        )
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            }
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }

    private func calibrationRectangle(size: CGSize, color: Color, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: max(4, cornerRadius), style: .continuous)
            .fill(color.opacity(0.12))
            .frame(width: size.width, height: max(2, size.height))
            .overlay(
                RoundedRectangle(cornerRadius: max(4, cornerRadius), style: .continuous)
                    .stroke(color.opacity(0.92), lineWidth: 2)
            )
            .shadow(color: color.opacity(0.35), radius: 8)
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

    private func expandedIdleSurface() -> some View {
        VStack(spacing: 0) {
            deadzoneTopBand(
                leading: {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("Top Notch")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                },
                trailing: {
                    Text(currentTimeString)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            )
            
            Group {
                let widgetType = settingsStore.settings.idleWidgetType
                switch widgetType {
                case "systemResources":
                    idleResourcesView
                case "retroSprite":
                    idleSpriteView
                case "weather":
                    idleWeatherView
                default:
                    idleDefaultView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
        }
    }

    private var idleResourcesView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "cpu")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.35, green: 0.67, blue: 1.0))
                    Text("CPU")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(Int(SystemResourceMonitor.shared.metrics.cpuUsage * 100))%")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(cpuColor(for: SystemResourceMonitor.shared.metrics.cpuUsage))
                            .frame(width: geo.size.width * CGFloat(SystemResourceMonitor.shared.metrics.cpuUsage))
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "memorychip")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.42, green: 0.86, blue: 0.58))
                    Text("RAM")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(String(format: "%.1fG/%.0fG", SystemResourceMonitor.shared.metrics.totalMemoryGB * SystemResourceMonitor.shared.metrics.memoryUsage, SystemResourceMonitor.shared.metrics.totalMemoryGB))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(Color(red: 0.42, green: 0.86, blue: 0.58))
                            .frame(width: geo.size.width * CGFloat(SystemResourceMonitor.shared.metrics.memoryUsage))
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 4)
    }

    private var idleSpriteView: some View {
        HStack(spacing: 12) {
            if let spriteType = PixelSpriteType(rawValue: settingsStore.settings.selectedSpriteType) {
                PixelSpriteView(spriteType: spriteType)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(spriteGreeting)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Standing by on the island...")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private var idleWeatherView: some View {
        HStack(spacing: 12) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Sunny • 22°C")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Precipitation: 0% | UV Index: 3")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private var idleDefaultView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("Top Notch Dashboard")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Click to expand main drop-down menu.")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private func cpuColor(for usage: Double) -> Color {
        if usage > 0.8 {
            return Color.red
        } else if usage > 0.5 {
            return Color.orange
        } else {
            return Color(red: 0.35, green: 0.67, blue: 1.0)
        }
    }

    private var spriteGreeting: String {
        switch settingsStore.settings.selectedSpriteType {
        case "cat":
            return "Meow! Cozy up here."
        case "ghost":
            return "Boo! Just chilling."
        case "star":
            return "Shine bright today!"
        default:
            return "Companion active."
        }
    }
}
