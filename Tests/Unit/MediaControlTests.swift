import XCTest
import Combine
@testable import TopNotchCore

final class MediaControlTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    @MainActor
    func testPlayPauseCallsProviderAndRefreshes() {
        let provider = MockMediaProvider()
        let store = MusicStateStore(provider: provider)
        
        provider.mockTrack = NowPlayingTrack(title: "Initial", artist: "Artist", album: "Album", duration: 100)
        provider.mockState = .stopped
        
        // Wait briefly for store initialization refresh to execute
        let expInit = self.expectation(description: "Initial refresh completes")
        store.$playbackState
            .filter { $0 == .stopped }
            .first()
            .sink { _ in
                expInit.fulfill()
            }
            .store(in: &cancellables)
        self.wait(for: [expInit], timeout: 2.0)
        
        // Setup updated state for after command execution
        let updatedTrack = NowPlayingTrack(title: "Playing Title", artist: "Artist", album: "Album", duration: 100)
        provider.mockTrack = updatedTrack
        provider.mockState = .playing
        
        let expectation = self.expectation(description: "Store state is refreshed after play/pause")
        store.$playbackState
            .filter { $0 == .playing }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        store.playpause()
        
        self.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(provider.playpauseCalled)
        XCTAssertEqual(store.currentTrack, updatedTrack)
    }
    
    @MainActor
    func testNextTrackCallsProviderAndRefreshes() {
        let provider = MockMediaProvider()
        let store = MusicStateStore(provider: provider)
        
        let expInit = self.expectation(description: "Initial refresh completes")
        store.$playbackState
            .filter { $0 == .unknown }
            .first()
            .sink { _ in
                expInit.fulfill()
            }
            .store(in: &cancellables)
        self.wait(for: [expInit], timeout: 2.0)
        
        // Setup updated state for after command execution
        let updatedTrack = NowPlayingTrack(title: "Next Track", artist: "Artist", album: "Album", duration: 100)
        provider.mockTrack = updatedTrack
        provider.mockState = .playing
        
        let expectation = self.expectation(description: "Store state is refreshed after nextTrack")
        store.$currentTrack
            .filter { $0?.title == "Next Track" }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        store.nextTrack()
        
        self.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(provider.nextTrackCalled)
    }
    
    @MainActor
    func testPreviousTrackCallsProviderAndRefreshes() {
        let provider = MockMediaProvider()
        let store = MusicStateStore(provider: provider)
        
        let expInit = self.expectation(description: "Initial refresh completes")
        store.$playbackState
            .filter { $0 == .unknown }
            .first()
            .sink { _ in
                expInit.fulfill()
            }
            .store(in: &cancellables)
        self.wait(for: [expInit], timeout: 2.0)
        
        // Setup updated state for after command execution
        let updatedTrack = NowPlayingTrack(title: "Previous Track", artist: "Artist", album: "Album", duration: 100)
        provider.mockTrack = updatedTrack
        provider.mockState = .playing
        
        let expectation = self.expectation(description: "Store state is refreshed after previousTrack")
        store.$currentTrack
            .filter { $0?.title == "Previous Track" }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
            
        store.previousTrack()
        
        self.wait(for: [expectation], timeout: 2.0)
        
        XCTAssertTrue(provider.previousTrackCalled)
    }
}
