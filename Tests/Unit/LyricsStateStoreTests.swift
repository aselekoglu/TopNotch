import XCTest
import Combine
@testable import TopNotchCore

final class MockLyricsProvider: LyricsProvider, @unchecked Sendable {
    let displayName = "Mock Lyrics Provider"
    
    var mockResult: Result<LyricsState, Error> = .success(.unavailable)
    var fetchCalledWithTrack: NowPlayingTrack?
    var delayNanoseconds: UInt64 = 0
    
    func fetchLyrics(for track: NowPlayingTrack) async throws -> LyricsState {
        fetchCalledWithTrack = track
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        switch mockResult {
        case .success(let state):
            return state
        case .failure(let error):
            throw error
        }
    }
}

final class LyricsStateStoreTests: XCTestCase {
    @MainActor
    func testDefaultState() async throws {
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(store.lyricsState, .unavailable)
        XCTAssertFalse(store.showLyrics)
    }
    
    @MainActor
    func testLoadingTransition() async throws {
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        lyricsProvider.delayNanoseconds = 100_000_000 // 100ms
        lyricsProvider.mockResult = .success(.plain("Done!"))
        
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let track = NowPlayingTrack(title: "Song", artist: "Artist", album: "Album", duration: 120.0)
        store.currentTrack = track
        
        // Assert that it immediately goes to .loading
        XCTAssertEqual(store.lyricsState, .loading)
        
        // Wait for final state
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(store.lyricsState, .plain("Done!"))
    }
    
    @MainActor
    func testPlainTextEmission() async throws {
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        lyricsProvider.mockResult = .success(.plain("Line 1\nLine 2"))
        
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let track = NowPlayingTrack(title: "Song", artist: "Artist", album: "Album", duration: 120.0)
        store.currentTrack = track
        
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(store.lyricsState, .plain("Line 1\nLine 2"))
    }
    
    @MainActor
    func testSyncedLyricsEmission() async throws {
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        let lines = [
            LyricsLine(text: "Hello", timestamp: 1.0),
            LyricsLine(text: "World", timestamp: 2.5)
        ]
        lyricsProvider.mockResult = .success(.synced(lines))
        
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let track = NowPlayingTrack(title: "Song", artist: "Artist", album: "Album", duration: 120.0)
        store.currentTrack = track
        
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(store.lyricsState, .synced(lines))
    }
    
    @MainActor
    func testUnavailableFallback() async throws {
        struct DummyError: Error {}
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        lyricsProvider.mockResult = .failure(DummyError())
        
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let track = NowPlayingTrack(title: "Song", artist: "Artist", album: "Album", duration: 120.0)
        store.currentTrack = track
        
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(store.lyricsState, .unavailable)
    }
    
    @MainActor
    func testTrackBecomesNilSetsUnavailable() async throws {
        let mediaProvider = MockMediaProvider()
        let lyricsProvider = MockLyricsProvider()
        lyricsProvider.mockResult = .success(.plain("Some lyrics"))
        
        let store = MusicStateStore(provider: mediaProvider, lyricsProvider: lyricsProvider)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        let track = NowPlayingTrack(title: "Song", artist: "Artist", album: "Album", duration: 120.0)
        store.currentTrack = track
        
        try await Task.sleep(nanoseconds: 20_000_000)
        XCTAssertEqual(store.lyricsState, .plain("Some lyrics"))
        
        store.currentTrack = nil
        XCTAssertEqual(store.lyricsState, .unavailable)
    }
}
