import XCTest
import Combine
@testable import TopNotchCore

final class MockMediaProvider: MediaProvider, @unchecked Sendable {
    var displayName: String = "Mock Provider"
    var mockIsRunning: Bool = true
    var mockTrack: NowPlayingTrack?
    var mockState: PlaybackState = .unknown
    
    func isRunning() -> Bool {
        return mockIsRunning
    }
    
    func queryCurrentTrack() async throws -> (track: NowPlayingTrack?, state: PlaybackState) {
        return (mockTrack, mockState)
    }
}

final class MusicStateStoreTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.removeAll()
        AppleMusicProbe.shared.resetCallbacksForTesting()
        super.tearDown()
    }
    
    @MainActor
    func testInitialRefreshState() {
        let provider = MockMediaProvider()
        let expectedTrack = NowPlayingTrack(title: "Test Title", artist: "Test Artist", album: "Test Album", duration: 180.0)
        provider.mockTrack = expectedTrack
        provider.mockState = .playing
        
        let store = MusicStateStore(provider: provider)
        
        let expectation = self.expectation(description: "Track is updated initially")
        
        store.$currentTrack
            .filter { $0 == expectedTrack }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        self.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertEqual(store.playbackState, .playing)
        XCTAssertEqual(store.currentTrack, expectedTrack)
    }
    
    @MainActor
    func testRefreshStateUpdatesValues() {
        let provider = MockMediaProvider()
        let store = MusicStateStore(provider: provider)
        
        let expectedTrack = NowPlayingTrack(title: "New Title", artist: "New Artist", album: "New Album", duration: 240.0)
        provider.mockTrack = expectedTrack
        provider.mockState = .paused
        
        let expectation = self.expectation(description: "Track is refreshed to paused")
        store.$playbackState
            .filter { $0 == .paused }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        store.refreshState()
        
        self.wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(store.currentTrack, expectedTrack)
    }
    
    @MainActor
    func testNotificationUpdatesStore() {
        let provider = MockMediaProvider()
        let store = MusicStateStore(provider: provider)
        
        let expectation = self.expectation(description: "Store updates via iTunes player info notification")
        
        store.$currentTrack
            .filter { $0?.title == "Notification Song" }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        let userInfo: [String: Any] = [
            "Player State": "Playing",
            "Name": "Notification Song",
            "Artist": "Notification Artist",
            "Album": "Notification Album",
            "Total Time": 120000
        ]
        
        NotificationCenter.default.post(
            name: NSNotification.Name("com.apple.iTunes.playerInfo"),
            object: nil,
            userInfo: userInfo
        )
        
        self.wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(store.playbackState, .playing)
        XCTAssertEqual(store.currentTrack?.artist, "Notification Artist")
        XCTAssertEqual(store.currentTrack?.album, "Notification Album")
        XCTAssertEqual(store.currentTrack?.duration, 120.0)
    }
}
