import SwiftUI
import TopNotchCore

/// A beautiful detailed Media Player Column for the center column of the expanded panel.
/// Features a real-time progress bar slider, track info, and playback controls.
struct NotchMediaPlayerColumn: View {
    @ObservedObject private var musicStore = MusicStateStore.shared
    @Binding var elapsed: Double
    
    @State private var isHoveredPrev = false
    @State private var isHoveredPlay = false
    @State private var isHoveredNext = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let track = musicStore.currentTrack {
                HStack(spacing: 12) {
                    albumArtwork
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(track.artist)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.64))
                            .lineLimit(1)
                        
                        Text(track.album)
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.white.opacity(0.44))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Seeker Bar
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 4)
                            
                            let progressFraction = track.duration > 0 ? CGFloat(elapsed / track.duration) : 0
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: max(0, min(geo.size.width, geo.size.width * progressFraction)), height: 4)
                            
                            // Handler knob
                            Circle()
                                .fill(Color.white)
                                .frame(width: 8, height: 8)
                                .offset(x: max(0, min(geo.size.width - 8, (geo.size.width * progressFraction) - 4)), y: -2)
                        }
                    }
                    .frame(height: 4)
                    
                    HStack {
                        Text(formatTime(elapsed))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.48))
                        Spacer()
                        Text(formatTime(track.duration))
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.48))
                    }
                }
                .padding(.top, 4)
                
                // Playback Controls
                HStack(spacing: 16) {
                    Spacer()
                    
                    Button(action: {
                        musicStore.previousTrack()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(isHoveredPrev ? 0.14 : 0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredPrev = $0 }
                    
                    Button(action: {
                        musicStore.playpause()
                    }) {
                        Image(systemName: musicStore.playbackState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(isHoveredPlay ? 0.18 : 0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredPlay = $0 }
                    
                    Button(action: {
                        musicStore.nextTrack()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(isHoveredNext ? 0.14 : 0.06))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .onHover { isHoveredNext = $0 }
                    
                    Spacer()
                }
                .padding(.top, 2)
                
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.24))
                    Text("No Track Playing")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.88))
                    Text("Start music in Apple Music")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.white.opacity(0.44))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.055))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }
    
    private var albumArtwork: some View {
        Group {
            if let urlString = musicStore.currentTrack?.artworkUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    placeholderArtwork
                }
            } else {
                placeholderArtwork
            }
        }
        .frame(width: 58, height: 58)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
    
    private var placeholderArtwork: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.78, green: 0.48, blue: 0.18),
                        Color(red: 0.33, green: 0.18, blue: 0.13),
                        Color(red: 0.08, green: 0.07, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            )
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
