import Foundation

public struct NowPlayingTrack: Equatable, Sendable, Identifiable {
    public var id: String {
        return "\(artist)-\(title)"
    }
    
    public let title: String
    public let artist: String
    public let album: String
    public let duration: Double
    public let artworkUrl: String?
    
    public init(title: String, artist: String, album: String, duration: Double, artworkUrl: String? = nil) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artworkUrl = artworkUrl
    }
}
