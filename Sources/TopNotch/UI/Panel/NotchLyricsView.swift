import SwiftUI
import TopNotchCore

/// A beautiful synced lyrics view to be nested in the U-shaped tab at the bottom of the panel.
/// Dynamically matches the active lyric line to the song progress, displaying the previous,
/// active, and next lyrics in a polished stack.
struct NotchLyricsView: View {
    @ObservedObject private var musicStore = MusicStateStore.shared
    let elapsed: Double
    
    var body: some View {
        VStack(spacing: 4) {
            switch musicStore.lyricsState {
            case .loading:
                Text("Loading lyrics...")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.44))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .unavailable:
                Text("No lyrics available")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.36))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .plain(let text):
                // Render first 3 lines of plain lyrics
                let lines = text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                VStack(spacing: 3) {
                    if lines.count > 0 {
                        Text(lines[0])
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    if lines.count > 1 {
                        Text(lines[1])
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    } else if lines.count == 1 {
                        // If only 1 line
                        Spacer().frame(height: 10)
                    }
                    if lines.count > 2 {
                        Text(lines[2])
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
                
            case .synced(let lines):
                if lines.isEmpty {
                    Text("No lyrics lines")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.36))
                        .lineLimit(1)
                } else {
                    let activeIndex = findActiveIndex(for: lines, time: elapsed)
                    
                    VStack(spacing: 2) {
                        // Previous line
                        if activeIndex > 0 {
                            Text(lines[activeIndex - 1].text)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        } else {
                            Text(" ")
                                .font(.system(size: 10))
                        }
                        
                        // Active line
                        Text(lines[activeIndex].text)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        // Next line
                        if activeIndex < lines.count - 1 {
                            Text(lines[activeIndex + 1].text)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        } else {
                            Text(" ")
                                .font(.system(size: 10))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
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
