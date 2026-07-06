import SwiftUI
import TopNotchCore

struct MusicWidgetView: View {
    @ObservedObject private var stateStore = MusicStateStore.shared
    @State private var isHoveredPrev = false
    @State private var isHoveredPlay = false
    @State private var isHoveredNext = false

    var body: some View {
        HStack(spacing: 16) {
            // Artwork Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.35, green: 0.15, blue: 0.6),
                                Color(red: 0.1, green: 0.05, blue: 0.25)
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 40
                        )
                    )
                    .frame(width: 54, height: 54)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                Image(systemName: "music.note")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            // Track Metadata
            VStack(alignment: .leading, spacing: 3) {
                if let track = stateStore.currentTrack {
                    Text(track.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(track.artist)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    Text(track.album)
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                } else {
                    Text("No Music Active")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Start playing in Music app")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            // Media Controls
            HStack(spacing: 12) {
                // Backward Button
                Button(action: {
                    stateStore.previousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(isHoveredPrev ? 0.15 : 0.06))
                        .clipShape(Circle())
                        .scaleEffect(isHoveredPrev ? 1.08 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHoveredPrev = hovering
                    }
                }
                
                // Play / Pause Button
                Button(action: {
                    stateStore.playpause()
                }) {
                    Image(systemName: stateStore.playbackState == .playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(isHoveredPlay ? 0.2 : 0.1))
                        .clipShape(Circle())
                        .scaleEffect(isHoveredPlay ? 1.08 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHoveredPlay = hovering
                    }
                }
                
                // Forward Button
                Button(action: {
                    stateStore.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(isHoveredNext ? 0.15 : 0.06))
                        .clipShape(Circle())
                        .scaleEffect(isHoveredNext ? 1.08 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHoveredNext = hovering
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}
