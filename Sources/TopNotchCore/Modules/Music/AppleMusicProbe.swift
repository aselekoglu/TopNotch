import Foundation
import AppKit

/// Metadata containing track title, artist, album, and duration.
public struct AppleMusicTrackMetadata: Equatable, Sendable {
    public let title: String
    public let artist: String
    public let album: String
    public let duration: Double
    public let playerPosition: Double
    
    public init(title: String, artist: String, album: String, duration: Double, playerPosition: Double = 0.0) {
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.playerPosition = playerPosition
    }
}

/// Enumeration of possible Apple Music playback states.
public enum AppleMusicPlaybackState: String, Sendable {
    case playing
    case paused
    case stopped
    case unknown
}

/// A prototype probe utility to detect Apple Music's playback state and track metadata.
public final class AppleMusicProbe: @unchecked Sendable {
    public static let shared = AppleMusicProbe()
    
    private var callbacks: [@Sendable (AppleMusicTrackMetadata?, AppleMusicPlaybackState) -> Void] = []
    private var isSubscribed = false
    private let lock = NSLock()
    
    public init() {}
    
    /// Determines whether the Apple Music application is currently running.
    public func isMusicAppRunning() -> Bool {
        return NSWorkspace.shared.runningApplications.contains { app in
            app.bundleIdentifier == "com.apple.Music"
        }
    }
    
    /// Queries the current track metadata and playback state directly using AppleScript.
    ///
    /// - Note: Requires Automation system permissions. If denied, catches error -1743 and returns `(nil, .unknown)`.
    public func queryCurrentTrackDirectly() -> (metadata: AppleMusicTrackMetadata?, state: AppleMusicPlaybackState) {
        guard isMusicAppRunning() else {
            return (nil, .stopped)
        }
        
        let scriptText = """
        tell application "Music"
            if player state is playing then
                set trk to current track
                set trkName to name of trk
                set trkArtist to artist of trk
                set trkAlbum to album of trk
                set trkDuration to duration of trk
                set trkPos to player position
                return "playing|" & trkName & "|" & trkArtist & "|" & trkAlbum & "|" & trkDuration & "|" & trkPos
            else if player state is paused then
                try
                    set trk to current track
                    set trkName to name of trk
                    set trkArtist to artist of trk
                    set trkAlbum to album of trk
                    set trkDuration to duration of trk
                    set trkPos to player position
                    return "paused|" & trkName & "|" & trkArtist & "|" & trkAlbum & "|" & trkDuration & "|" & trkPos
                on error
                    return "paused|unknown|unknown|unknown|0.0|0.0"
                end try
            else
                return "stopped|unknown|unknown|unknown|0.0|0.0"
            end if
        end tell
        """
        
        guard let appleScript = NSAppleScript(source: scriptText) else {
            return (nil, .unknown)
        }
        
        var errorInfo: NSDictionary?
        let result = appleScript.executeAndReturnError(&errorInfo)
        
        if let error = errorInfo {
            let errorNumber = error[NSAppleScript.errorNumber] as? Int ?? 0
            if errorNumber == -1743 {
                // Automation permission denied
                print("[AppleMusicProbe] Automation permission denied (error -1743).")
            } else {
                print("[AppleMusicProbe] AppleScript execution error: \(error)")
            }
            return (nil, .unknown)
        }
        
        guard let resultString = result.stringValue else {
            return (nil, .unknown)
        }
        
        let parts = resultString.components(separatedBy: "|")
        guard parts.count >= 5 else {
            return (nil, .unknown)
        }
        
        let stateStr = parts[0]
        let title = parts[1]
        let artist = parts[2]
        let album = parts[3]
        let duration = Double(parts[4]) ?? 0.0
        let playerPosition = parts.count >= 6 ? (Double(parts[5]) ?? 0.0) : 0.0
        
        let state: AppleMusicPlaybackState
        switch stateStr {
        case "playing": state = .playing
        case "paused": state = .paused
        case "stopped": state = .stopped
        default: state = .unknown
        }
        
        if title == "unknown" && artist == "unknown" {
            return (nil, state)
        }
        
        let metadata = AppleMusicTrackMetadata(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            playerPosition: playerPosition
        )
        return (metadata, state)
    }
    
    /// Subscribes to player info notifications from the distributed notification center.
    ///
    /// - Parameter onChanged: Closure to run when a playback state or track change notification is received.
    public func startObservingNotifications(onChanged: @escaping @Sendable (AppleMusicTrackMetadata?, AppleMusicPlaybackState) -> Void) {
        lock.lock()
        callbacks.append(onChanged)
        let needsSubscription = !isSubscribed
        isSubscribed = true
        lock.unlock()
        
        guard needsSubscription else { return }
        
        let handler: @Sendable (Notification) -> Void = { [weak self] notification in
            guard let userInfo = notification.userInfo else { return }
            
            let playerStateStr = userInfo["Player State"] as? String ?? ""
            let name = userInfo["Name"] as? String ?? ""
            let artist = userInfo["Artist"] as? String ?? ""
            let album = userInfo["Album"] as? String ?? ""
            let durationMs = userInfo["Total Time"] as? Int ?? 0
            let durationSec = Double(durationMs) / 1000.0
            
            let state: AppleMusicPlaybackState
            switch playerStateStr {
            case "Playing": state = .playing
            case "Paused": state = .paused
            case "Stopped": state = .stopped
            default: state = .unknown
            }
            
            let metadata = name.isEmpty ? nil : AppleMusicTrackMetadata(title: name, artist: artist, album: album, duration: durationSec, playerPosition: 0.0)
            
            guard let self = self else { return }
            self.lock.lock()
            let currentCallbacks = self.callbacks
            self.lock.unlock()
            
            for callback in currentCallbacks {
                callback(metadata, state)
            }
        }
        
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.apple.iTunes.playerInfo"),
            object: nil,
            queue: .main,
            using: handler
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("com.apple.iTunes.playerInfo"),
            object: nil,
            queue: .main,
            using: handler
        )
    }
    
    public func resetCallbacksForTesting() {
        lock.lock()
        defer { lock.unlock() }
        callbacks.removeAll()
    }
}
