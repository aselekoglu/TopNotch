import SwiftUI
import TopNotchCore

struct MusicWidgetView: View {
    @ObservedObject private var stateStore = MusicStateStore.shared
    @State private var isHoveredPrev = false
    @State private var isHoveredPlay = false
    @State private var isHoveredNext = false
    @State private var isHoveredLyrics = false
    @State private var isPulsing = false

    var body: some View {
        if stateStore.currentTrack == nil {
            inactiveMusicCard
        } else {
            activeMusicCard
        }
    }

    private var activeMusicCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
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
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                
                Spacer()
                
                HStack(spacing: 12) {
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

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            stateStore.showLyrics.toggle()
                        }
                    }) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 13))
                            .foregroundColor(stateStore.showLyrics ? .white : .white.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(stateStore.showLyrics ? 0.25 : (isHoveredLyrics ? 0.15 : 0.06)))
                            .clipShape(Circle())
                            .scaleEffect(isHoveredLyrics ? 1.08 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isHoveredLyrics = hovering
                        }
                    }
                }
            }
            
            if stateStore.showLyrics {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.vertical, 8)
                
                lyricsContainer
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.055))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private var inactiveMusicCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.10, blue: 0.40),
                                Color(red: 0.06, green: 0.05, blue: 0.11)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 42, height: 42)

                Image(systemName: "music.note")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.80))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Music")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))

                Text("No track playing")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.46))
            }

            Spacer()

            Image(systemName: "waveform")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.28))
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.06))
                .clipShape(Circle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var lyricsContainer: some View {
        VStack {
            switch stateStore.lyricsState {
            case .loading:
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Yükleniyor...")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(isPulsing ? 0.3 : 1.0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .transition(.opacity)
                
            case .unavailable:
                Text("Lyrics Yok")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .transition(.opacity)
                    
            case .plain(let text):
                ScrollView(.vertical, showsIndicators: false) {
                    Text(text)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 4)
                }
                .frame(maxHeight: 120)
                .transition(.opacity)
                
            case .synced(let lines):
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(lines) { line in
                            Text(line.text)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: 120)
                .transition(.opacity)
            }
        }
    }
}
