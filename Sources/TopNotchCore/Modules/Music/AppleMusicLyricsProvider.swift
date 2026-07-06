import Foundation

public final class AppleMusicLyricsProvider: LyricsProvider {
    public let displayName = "Apple Music Local"
    
    public init() {}
    
    public func fetchLyrics(for track: NowPlayingTrack) async throws -> LyricsState {
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
}
