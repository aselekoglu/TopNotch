#if canImport(AppKit)
import AppKit
#endif

@MainActor
public final class MusicStateStore: ObservableObject, @unchecked Sendable {
    public static let shared = MusicStateStore(provider: AppleMusicProvider())

    @Published public var dominantColorHex: String? = nil

    @Published public var currentTrack: NowPlayingTrack? {
        didSet {
            guard oldValue?.id != currentTrack?.id else { return }
            lyricsFetchTask?.cancel()
            lyricsFetchTask = nil
            artworkFetchTask?.cancel()
            artworkFetchTask = nil
            
            if currentTrack == nil {
                self.lyricsState = .unavailable
                self.dominantColorHex = nil
            } else {
                self.lyricsState = .loading
                self.dominantColorHex = nil
                if let artwork = currentTrack?.artworkUrl {
                    updateDominantColor(for: artwork)
                }
                lyricsFetchTask = Task {
                    await fetchLyrics()
                }
                artworkFetchTask = Task {
                    await fetchArtwork()
                }
            }
        }
    }
    @Published public var playbackState: PlaybackState = .unknown
    @Published public var lyricsState: LyricsState = .unavailable
    @Published public var showLyrics: Bool = false
    @Published public var playerPosition: Double = 0.0
    
    private let provider: MediaProvider
    private let lyricsProvider: LyricsProvider
    private var lyricsFetchTask: Task<Void, Never>?
    private var artworkFetchTask: Task<Void, Never>?
    private var positionTimer: Timer?
    
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
        
        // Start real-time position polling timer
        self.positionTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updatePlayerPosition()
            }
        }
        
        // Trigger initial refresh
        refreshState()
    }
    
    public func refreshState() {
        Task {
            do {
                let (track, state) = try await provider.queryCurrentTrack()
                self.playbackState = state
                if track != nil {
                    // Update initial playhead position
                    let script = "tell application \"Music\" to get player position"
                    if let appleScript = NSAppleScript(source: script) {
                        var err: NSDictionary?
                        let res = appleScript.executeAndReturnError(&err)
                        if err == nil, let text = res.stringValue, let pos = Double(text) {
                            self.playerPosition = pos
                        }
                    }
                }
                self.currentTrack = track
            } catch {
                self.playbackState = .unknown
                self.currentTrack = nil
            }
        }
    }
    
    private func updatePlayerPosition() {
        guard playbackState == .playing else { return }
        let script = "tell application \"Music\" to get player position"
        guard let appleScript = NSAppleScript(source: script) else { return }
        var errorInfo: NSDictionary?
        let result = appleScript.executeAndReturnError(&errorInfo)
        if errorInfo == nil, let text = result.stringValue, let pos = Double(text) {
            self.playerPosition = pos
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
    
    public func fetchArtwork() async {
        guard let track = currentTrack, track.artworkUrl == nil else { return }
        let term = "\(track.artist) \(track.title)"
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&entity=song&limit=1"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            struct iTunesResponse: Codable {
                struct Result: Codable {
                    let artworkUrl100: String?
                }
                let results: [Result]
            }
            let response = try JSONDecoder().decode(iTunesResponse.self, from: data)
            if let url100 = response.results.first?.artworkUrl100 {
                let highResUrl = url100.replacingOccurrences(of: "100x100bb", with: "500x500bb")
                guard !Task.isCancelled else { return }
                if self.currentTrack?.id == track.id {
                    self.currentTrack = NowPlayingTrack(
                        title: track.title,
                        artist: track.artist,
                        album: track.album,
                        duration: track.duration,
                        artworkUrl: highResUrl
                    )
                    updateDominantColor(for: highResUrl)
                }
            }
        } catch {
            print("[MusicStateStore] iTunes artwork search failed: \(error)")
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
            self.playerPosition = metadata.playerPosition
        } else {
            track = nil
            self.playerPosition = 0.0
        }
        
        self.currentTrack = track
        self.playbackState = mappedState
    }

    private func updateDominantColor(for urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.dominantColorHex = nil
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                #if canImport(AppKit)
                if let image = NSImage(data: data) {
                    let hex = image.dominantColor().toHexString()
                    await MainActor.run {
                        self.dominantColorHex = hex
                    }
                }
                #endif
            } catch {
                print("[MusicStateStore] Failed to fetch dominant color for \(urlString): \(error)")
            }
        }
    }
}

#if canImport(AppKit)
extension NSImage {
    func dominantColor() -> NSColor {
        let newSize = NSSize(width: 10, height: 10)
        guard let representation = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(newSize.width),
            pixelsHigh: Int(newSize.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return .white
        }
        
        representation.size = newSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: representation)
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size), operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var count: CGFloat = 0
        
        for y in 0..<10 {
            for x in 0..<10 {
                if let color = representation.colorAt(x: x, y: y) {
                    r += color.redComponent
                    g += color.greenComponent
                    b += color.blueComponent
                    count += 1
                }
            }
        }
        
        if count == 0 { return .white }
        return NSColor(red: r / count, green: g / count, blue: b / count, alpha: 1.0)
    }
}

extension NSColor {
    func toHexString() -> String {
        guard let rgb = self.usingColorSpace(.sRGB) else { return "#FFFFFF" }
        let r = Int(rgb.redComponent * 255)
        let g = Int(rgb.greenComponent * 255)
        let b = Int(rgb.blueComponent * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
#endif
