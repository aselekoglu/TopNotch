import Foundation

public enum LyricsState: Equatable, Sendable {
    case loading
    case unavailable
    case plain(String)
    case synced([LyricsLine])
}

public struct LyricsLine: Equatable, Sendable, Identifiable {
    public var id: Double { timestamp }
    public let text: String
    public let timestamp: Double
    
    public init(text: String, timestamp: Double) {
        self.text = text
        self.timestamp = timestamp
    }
}
