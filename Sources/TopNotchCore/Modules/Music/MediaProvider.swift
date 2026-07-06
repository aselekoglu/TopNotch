import Foundation

public protocol MediaProvider: Sendable {
    var displayName: String { get }
    func isRunning() -> Bool
    func queryCurrentTrack() async throws -> (track: NowPlayingTrack?, state: PlaybackState)
    func playpause() async throws
    func nextTrack() async throws
    func previousTrack() async throws
}
