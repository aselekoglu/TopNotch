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
}
