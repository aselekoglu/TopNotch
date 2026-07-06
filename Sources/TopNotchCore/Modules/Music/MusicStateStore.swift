import Foundation
import Combine

@MainActor
public final class MusicStateStore: ObservableObject, @unchecked Sendable {
    @Published public var currentTrack: NowPlayingTrack?
    @Published public var playbackState: PlaybackState = .unknown
    
    private let provider: MediaProvider
    
    public init(provider: MediaProvider) {
        self.provider = provider
        
        // Start observing notifications using AppleMusicProbe.shared
        AppleMusicProbe.shared.startObservingNotifications { [weak self] metadata, state in
            DispatchQueue.main.async {
                if let self = self {
                    MainActor.assumeIsolated {
                        self.handleNotification(metadata: metadata, state: state)
                    }
                }
            }
        }
        
        // Trigger initial refresh
        refreshState()
    }
    
    public func refreshState() {
        Task {
            do {
                let (track, state) = try await provider.queryCurrentTrack()
                self.currentTrack = track
                self.playbackState = state
            } catch {
                self.playbackState = .unknown
                self.currentTrack = nil
            }
        }
    }
    
    private func handleNotification(metadata: AppleMusicTrackMetadata?, state: AppleMusicPlaybackState) {
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
        
        let track: NowPlayingTrack?
        if let metadata = metadata {
            track = NowPlayingTrack(
                title: metadata.title,
                artist: metadata.artist,
                album: metadata.album,
                duration: metadata.duration
            )
        } else {
            track = nil
        }
        
        self.currentTrack = track
        self.playbackState = mappedState
    }
}
