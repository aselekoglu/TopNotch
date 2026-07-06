import Foundation

public struct NowPlayingTrack: Equatable, Sendable, Identifiable {
    public var id: String { "\(title)-\(artist)" }
    public let title: String
    public let artist: String
    public let album: String
    public let duration: Double
    
    public init(title: String, artist: String, album: String, duration: Double) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
    }
}
