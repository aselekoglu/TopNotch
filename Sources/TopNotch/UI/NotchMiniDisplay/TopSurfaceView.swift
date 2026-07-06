import SwiftUI
import TopNotchCore

/// A SwiftUI view representing the top surface pill (virtual island or physical notch overlay).
struct TopSurfaceView: View {
    /// The top safe area inset of the current display. If > 0, we assume the screen has a physical notch.
    let safeAreaTopInset: CGFloat
    
    /// Callback triggered when the pill is clicked.
    let onTap: () -> Void
    
    /// Tracks whether the mouse cursor is currently hovering over the pill.
    @State private var isHovered = false
    
    @ObservedObject private var stateStore = MusicStateStore.shared
    
    // Hover states for mini media buttons
    @State private var isHoveredPrevMini = false
    @State private var isHoveredPlayMini = false
    @State private var isHoveredNextMini = false
    
    /// Returns true if the target display screen has a physical notch.
    var hasNotch: Bool {
        safeAreaTopInset > 0
    }
    
    /// Computes the target width of the pill based on notch presence, playback, and hover state.
    var targetWidth: CGFloat {
        let playing = stateStore.playbackState == .playing
        if playing {
            return isHovered ? 360 : 300
        }
        return isHovered ? 300 : 240
    }
    
    /// Computes the target height of the pill based on notch presence, playback, and hover state.
    var targetHeight: CGFloat {
        let playing = stateStore.playbackState == .playing
        if hasNotch {
            if playing {
                return isHovered ? 82 : max(52, min(64, safeAreaTopInset))
            } else {
                return isHovered ? 58 : max(44, min(56, safeAreaTopInset))
            }
        } else {
            if playing {
                return isHovered ? 74 : 46
            } else {
                return isHovered ? 54 : 38
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
            // (24pt standard menu bar - 22pt idle height) / 2 = 1pt to center vertically
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
                
                if playing {
                    if isHovered {
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
                    compactIdleSurface(title: isHovered ? "Top Notch" : "")
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

        return UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: targetCornerRadius, bottomLeading: targetCornerRadius, bottomTrailing: targetCornerRadius, topTrailing: targetCornerRadius), style: .continuous)
    }

    private func compactNowPlaying(_ track: NowPlayingTrack) -> some View {
        HStack(spacing: 0) {
            albumBadge(size: 34, cornerRadius: 9)
                .padding(.leading, 18)

            Spacer()

            equalizerIcon
                .scaleEffect(0.72)
                .padding(.trailing, 20)
        }
        .overlay(
            Text(track.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.0))
                .lineLimit(1)
        )
    }

    private func expandedNowPlaying(_ track: NowPlayingTrack) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                albumBadge(size: 42, cornerRadius: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(track.artist)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.56))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)

                equalizerIcon
                    .scaleEffect(0.76)
            }

            HStack(spacing: 8) {
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

                Text(track.album.isEmpty ? "Now Playing" : track.album)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.42))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func compactIdleSurface(title: String) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(isHovered ? Color.green : Color.white.opacity(0.32))
                .frame(width: 7, height: 7)

            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.88))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
    }

    private func albumBadge(size: CGFloat, cornerRadius: CGFloat) -> some View {
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
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .frame(width: size, height: size)

            RoundedRectangle(cornerRadius: size * 0.16, style: .continuous)
                .fill(Color(red: 1.0, green: 0.17, blue: 0.32))
                .frame(width: size * 0.34, height: size * 0.34)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: size * 0.18, weight: .bold))
                        .foregroundColor(.white)
                )
                .offset(x: size * 0.09, y: size * 0.09)
        }
        .frame(width: size, height: size)
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
}
