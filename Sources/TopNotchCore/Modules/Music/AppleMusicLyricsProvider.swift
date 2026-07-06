import Foundation

public final class AppleMusicLyricsProvider: LyricsProvider {
    public let displayName = "Apple Music Local & LRCLIB"
    
    public init() {}
    
    public func fetchLyrics(for track: NowPlayingTrack) async throws -> LyricsState {
        // 1. Try fetching from LRCLIB first for time-synced lyrics
        if let lrclibState = await fetchFromLRCLIB(for: track) {
            return lrclibState
        }
        
        // 2. Fall back to AppleScript to query local/cached lyrics
        let scriptText = """
        tell application "Music"
            try
                return lyrics of current track
            on error
                return ""
            end try
        end tell
        """
        guard let appleScript = NSAppleScript(source: scriptText) else {
            return .unavailable
        }
        var errorInfo: NSDictionary?
        let result = appleScript.executeAndReturnError(&errorInfo)
        if errorInfo != nil {
            return .unavailable
        }
        guard let text = result.stringValue, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .unavailable
        }
        return .plain(text)
    }
    
    private func fetchFromLRCLIB(for track: NowPlayingTrack) async -> LyricsState? {
        let query = "\(track.artist) \(track.title)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        let urlString = "https://lrclib.net/api/search?q=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("TopNotch/1.0 (https://github.com/aselekoglu/TopNotch)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            struct LRCSongResult: Codable {
                let syncedLyrics: String?
                let plainLyrics: String?
            }
            
            let results = try JSONDecoder().decode([LRCSongResult].self, from: data)
            for result in results {
                if let synced = result.syncedLyrics, !synced.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let parsedLines = parseLRC(synced)
                    if !parsedLines.isEmpty {
                        return .synced(parsedLines)
                    }
                }
                if let plain = result.plainLyrics, !plain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return .plain(plain)
                }
            }
        } catch {
            print("[AppleMusicLyricsProvider] LRCLIB request failed: \(error)")
        }
        
        return nil
    }
    
    private func parseLRC(_ lrcText: String) -> [LyricsLine] {
        var lines: [LyricsLine] = []
        let rawLines = lrcText.components(separatedBy: .newlines)
        
        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.hasPrefix("["), let closingBracketIndex = trimmed.firstIndex(of: "]") else {
                continue
            }
            
            let timestampStart = trimmed.index(after: trimmed.startIndex)
            let timestampStr = String(trimmed[timestampStart..<closingBracketIndex])
            let text = String(trimmed[trimmed.index(after: closingBracketIndex)...]).trimmingCharacters(in: .whitespaces)
            
            let parts = timestampStr.components(separatedBy: ":")
            guard parts.count >= 2 else { continue }
            
            guard let minVal = Double(parts[0]),
                  let secVal = Double(parts[1]) else {
                continue // Skips metadata tags like [ar: Artist]
            }
            
            let totalSeconds = minVal * 60.0 + secVal
            lines.append(LyricsLine(text: text, timestamp: totalSeconds))
        }
        
        return lines.sorted { $0.timestamp < $1.timestamp }
    }
}
