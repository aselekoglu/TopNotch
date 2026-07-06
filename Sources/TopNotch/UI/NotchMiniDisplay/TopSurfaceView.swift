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
        if hasNotch {
            if playing {
                return isHovered ? 280 : 220
            } else {
                return isHovered ? 240 : 200
            }
        } else {
            if playing {
                return isHovered ? 260 : 200
            } else {
                return isHovered ? 200 : 160
            }
        }
    }
    
    /// Computes the target height of the pill based on notch presence, playback, and hover state.
    var targetHeight: CGFloat {
        let playing = stateStore.playbackState == .playing
        if hasNotch {
            if playing {
                return isHovered ? 68 : safeAreaTopInset
            } else {
                return isHovered ? 48 : safeAreaTopInset
            }
        } else {
            if playing {
                return isHovered ? 68 : 22
            } else {
                return isHovered ? 38 : 22
            }
        }
    }
    
    /// Computes the corner radius for the visual appearance.
    var targetCornerRadius: CGFloat {
        if hasNotch {
            // For a physical notch, only the bottom corners are typically rounded by the OS, 
            // but a uniform 12pt corner radius provides a smooth, native look under expansion.
            return 12
        } else {
            // Virtual island uses a fully rounded pill style.
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
                // Background shape with standard macOS dark color / black to match bezel/notch
                RoundedRectangle(cornerRadius: targetCornerRadius, style: .continuous)
                    .fill(Color.black)
                
                // Content container
                if playing {
                    if isHovered {
                        // Expanded Live Activity
                        if let track = stateStore.currentTrack {
                            VStack(spacing: 0) {
                                if hasNotch {
                                    Spacer().frame(height: safeAreaTopInset)
                                } else {
                                    Spacer()
                                }
                                
                                HStack(spacing: 8) {
                                    // Mini artwork
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "music.note")
                                            .font(.system(size: 11))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(track.title)
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                        Text(track.artist)
                                            .font(.system(size: 9, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: 110, alignment: .leading)
                                    
                                    Spacer(minLength: 4)
                                    
                                    // Miniature media controls
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            stateStore.previousTrack()
                                        }) {
                                            Image(systemName: "backward.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(.white)
                                                .frame(width: 22, height: 22)
                                                .background(Color.white.opacity(isHoveredPrevMini ? 0.2 : 0.05))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .onHover { h in isHoveredPrevMini = h }
                                        
                                        Button(action: {
                                            stateStore.playpause()
                                        }) {
                                            Image(systemName: stateStore.playbackState == .playing ? "pause.fill" : "play.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(.white)
                                                .frame(width: 22, height: 22)
                                                .background(Color.white.opacity(isHoveredPlayMini ? 0.25 : 0.1))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .onHover { h in isHoveredPlayMini = h }
                                        
                                        Button(action: {
                                            stateStore.nextTrack()
                                        }) {
                                            Image(systemName: "forward.fill")
                                                .font(.system(size: 9))
                                                .foregroundColor(.white)
                                                .frame(width: 22, height: 22)
                                                .background(Color.white.opacity(isHoveredNextMini ? 0.2 : 0.05))
                                                .clipShape(Circle())
                                        }
                                        .buttonStyle(.plain)
                                        .onHover { h in isHoveredNextMini = h }
                                    }
                                }
                                .padding(.horizontal, 12)
                                
                                Spacer()
                            }
                        }
                    } else {
                        // Playing but not hovered
                        if let track = stateStore.currentTrack {
                            Text("🎵 \(track.title) - \(track.artist)")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                        } else {
                            Text("🎵 Music")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                        }
                    }
                } else {
                    // Not playing
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isHovered ? Color.green : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                        
                        if isHovered {
                            Text("Top Notch")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    }
                    .padding(.horizontal, 10)
                }
            }
            .frame(width: targetWidth, height: targetHeight)
            .overlay(
                RoundedRectangle(cornerRadius: targetCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isHovered ? 0.15 : 0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovered ? 0.4 : 0.15), radius: isHovered ? 8 : 3, y: isHovered ? 4 : 1.5)
            // A fluid spring animation for organic Liquid Glass physical feel
            .animation(.spring(response: 0.28, dampingFraction: 0.75, blendDuration: 0), value: isHovered)
            .animation(.spring(response: 0.28, dampingFraction: 0.75, blendDuration: 0), value: stateStore.playbackState)
            .onHover { hovering in
                isHovered = hovering
            }
            // Clicking the pill toggles the main panel
            .onTapGesture {
                onTap()
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
