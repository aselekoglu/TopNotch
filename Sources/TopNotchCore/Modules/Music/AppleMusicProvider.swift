import Foundation

public final class AppleMusicProvider: MediaProvider {
    public let displayName: String = "Apple Music"
    private let probe: AppleMusicProbe
    
    public init(probe: AppleMusicProbe = .shared) {
        self.probe = probe
    }
    
    public func isRunning() -> Bool {
        return probe.isMusicAppRunning()
    }
    
    public func queryCurrentTrack() async throws -> (track: NowPlayingTrack?, state: PlaybackState) {
        let (metadata, state) = probe.queryCurrentTrackDirectly()
        
        let mappedState: PlaybackState
        switch state {
        case .playing:
            mappedState = .playing
        case .paused:
            mappedState = .paused
        case .stopped:
            mappedState = .stopped
        case .unknown:
            mappedState = .unknown
        }
        
        guard let metadata = metadata else {
            return (nil, mappedState)
        }
        
        let track = NowPlayingTrack(
            title: metadata.title,
            artist: metadata.artist,
            album: metadata.album,
            duration: metadata.duration
        )
        return (track, mappedState)
    }
    
    public func playpause() async throws {
        try await executeScript("tell application \"Music\" to playpause")
    }
    
    public func nextTrack() async throws {
        try await executeScript("tell application \"Music\" to next track")
    }
    
    public func previousTrack() async throws {
        try await executeScript("tell application \"Music\" to previous track")
    }
    
    private func executeScript(_ source: String) async throws {
        guard let appleScript = NSAppleScript(source: source) else {
            throw NSError(domain: "AppleMusicProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create NSAppleScript"])
        }
        var errorInfo: NSDictionary?
        _ = appleScript.executeAndReturnError(&errorInfo)
        if let error = errorInfo {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? 0
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown AppleScript error"
            print("[AppleMusicProvider] AppleScript execution error: \(errorMessage) (code: \(errorNumber))")
            throw NSError(domain: "AppleMusicProvider", code: errorNumber, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
    }
}
