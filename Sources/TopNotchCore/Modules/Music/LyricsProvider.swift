import Foundation

public protocol LyricsProvider: Sendable {
    var displayName: String { get }
    func fetchLyrics(for track: NowPlayingTrack) async throws -> LyricsState
}
