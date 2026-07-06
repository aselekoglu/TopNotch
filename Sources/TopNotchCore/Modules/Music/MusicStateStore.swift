import Foundation
import Combine

@MainActor
public final class MusicStateStore: ObservableObject, @unchecked Sendable {
    public static let shared = MusicStateStore(provider: AppleMusicProvider())

    @Published public var currentTrack: NowPlayingTrack? {
        didSet {
            guard oldValue != currentTrack else { return }
            lyricsFetchTask?.cancel()
            lyricsFetchTask = nil
            
            if currentTrack == nil {
                self.lyricsState = .unavailable
            } else {
                self.lyricsState = .loading
                lyricsFetchTask = Task {
                    await fetchLyrics()
                }
            }
        }
    }
    @Published public var playbackState: PlaybackState = .unknown
    @Published public var lyricsState: LyricsState = .unavailable
    @Published public var showLyrics: Bool = false
    
    private let provider: MediaProvider
    private let lyricsProvider: LyricsProvider
    private var lyricsFetchTask: Task<Void, Never>?
    
    public init(provider: MediaProvider, lyricsProvider: LyricsProvider = AppleMusicLyricsProvider()) {
        self.provider = provider
        self.lyricsProvider = lyricsProvider
        
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
    
    public func fetchLyrics() async {
        guard let track = currentTrack else {
            self.lyricsState = .unavailable
            return
        }
        
        do {
            let state = try await lyricsProvider.fetchLyrics(for: track)
            guard !Task.isCancelled else { return }
            self.lyricsState = state
        } catch {
            guard !Task.isCancelled else { return }
            self.lyricsState = .unavailable
        }
    }
    
    public func playpause() {
        Task {
            do {
                try await provider.playpause()
                refreshState()
            } catch {
                print("[MusicStateStore] Play/Pause command failed: \(error)")
            }
        }
    }
    
    public func nextTrack() {
        Task {
            do {
                try await provider.nextTrack()
                refreshState()
            } catch {
                print("[MusicStateStore] Next Track command failed: \(error)")
            }
        }
    }
    
    public func previousTrack() {
        Task {
            do {
                try await provider.previousTrack()
                refreshState()
            } catch {
                print("[MusicStateStore] Previous Track command failed: \(error)")
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
