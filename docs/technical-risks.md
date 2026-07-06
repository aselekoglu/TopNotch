# Technical Risks and Feasibility: Apple Music Integration

This document outlines the findings, permission requirements, and architectural recommendations for observing Apple Music now-playing metadata and fetching lyrics on macOS.

---

## 1. Apple Music Now-Playing Detection

We evaluated three primary methods for detecting Apple Music's current playback state and track metadata (Title, Artist, Album, Duration) on macOS:

### Comparison of Methods

| Method | Pros | Cons | Permissions Required |
| :--- | :--- | :--- | :--- |
| **DistributedNotificationCenter**<br>(`com.apple.iTunes.playerInfo`) | • Extremely lightweight and passive.<br>• Real-time updates on play/pause/skip.<br>• **Does not launch** Music.app if closed. | • Only triggers on state change events.<br>• Cannot query the initial state on app launch. | **None** (runs entirely without sandboxing or user permission prompts). |
| **AppleScript / ScriptingBridge** | • Can query full state on-demand.<br>• Access to extensive track properties. | • Slow / blocking execution if not run asynchronously.<br>• **Launches Music.app** if closed (requires NSRunningApplication check). | **Automation Permission** (`NSAppleEventsUsageDescription` in Info.plist). Denying this yields error `-1743`. |
| **MediaPlayer Framework**<br>(`MPNowPlayingInfoCenter`) | • Native public API. | • Write-only on macOS for setting your own app's playing info, not reading other apps' info. | N/A (Cannot be used). |
| **MediaRemote Private Framework**<br>(`MRMediaRemote`) | • Provides system-wide now-playing info. | • Private API: risk of App Store rejection.<br>• Highly fragile (known to break in macOS 15+). | None (but unsafe for production). |

### Recommended Hybrid Architecture

To achieve a reliable, zero-prompt, and launch-safe experience, we recommend a **hybrid architecture**:

1. **Passive Event Tracking**:
   Subscribe to `com.apple.iTunes.playerInfo` notifications in `DistributedNotificationCenter.default()`. This receives immediate updates for playback state, track title, artist, album, and duration without requesting any system permissions.
2. **Safe Initial Query**:
   On app launch, check if Apple Music is running via `NSWorkspace.shared.runningApplications`.
   - If Music.app is **not running**, remain idle and wait for notification events (prevents launching Music.app).
   - If Music.app **is running**, attempt a single AppleScript query to get the current track metadata.
3. **Graceful Degradation**:
   If the user has denied Automation permission (or has not yet granted it), the AppleScript call will fail with error `-1743` (`errAEEventNotAllowed`). We catch this error, log it, and gracefully fall back to relying purely on `DistributedNotificationCenter` updates (which still work!).

---

## 2. Lyrics and Synced Lyrics Feasibility

We investigated retrieving lyrics programmatically, with the following findings:

### Limitations & Roadblocks

1. **No Public MusicKit Lyrics API**:
   Apple Music / MusicKit APIs (including `ApplicationMusicPlayer` and `SystemMusicPlayer`) do **not** expose lyrics text or time-synced lyrics data to third-party developers. The MusicKit `Song` model contains a `hasLyrics` boolean, but no content properties.
2. **AppleScript Limitations**:
   The AppleScript `lyrics` property is only populated for **local, downloaded, or user-added tracks** in the user's Music library. For Apple Music streaming/subscription tracks, this property is empty (`""`) or throws an error.
3. **Private Web Player Reverse-Engineering**:
   While it is technically possible to scrape private web player endpoints using developer tokens, these endpoints are undocumented, highly volatile, subject to rate limits, and violate Apple's Terms of Service.

### Recommended Lyrics Fallback Strategy

Since official synced lyrics cannot be programmatically accessed, we recommend implementing the following fallback model:

```
                  ┌──────────────────────────────┐
                  │      Song Metadata Changed    │
                  └──────────────┬───────────────┘
                                 │
                                 ▼
                  ┌──────────────────────────────┐
                  │ Check local track metadata   │
                  │       via AppleScript        │
                  └──────────────┬───────────────┘
                                 │
                   Lyrics found? ├───────────► [Show Unsynced Lyrics]
                                 │ No
                                 ▼
                  ┌──────────────────────────────┐
                  │ Query open APIs (e.g. LrcLib)│
                  │  or check local .lrc import  │
                  └──────────────┬───────────────┘
                                 │
                   Lyrics found? ├───────────► [Show Synced/Plain Lyrics]
                                 │ No
                                 ▼
                  ┌──────────────────────────────┐
                  │    Fall back to "Lyrics Yok" │
                  └──────────────────────────────┘
```

1. **State Isolation**: Use a `LyricsState` enum with `synced(lines: [LyricsLine])`, `plain(text: String)`, `unavailable`, and `loading` states.
2. **Provider Boundary**: Isolate lyrics lookup behind a `LyricsProvider` protocol, allowing us to swap or stack providers (e.g., local, open metadata APIs, or user LRC import) without altering the UI.
3. **Product Mitigation**: Clear messaging ("Lyrics Yok") when lyrics are unavailable, as approved in the MVP spec.

---

## 3. Sandboxing & Hardening Considerations

- **Automation Sandbox Exception**: If the app is sandboxed, we must add the `com.apple.security.temporary-exception.apple-events` entitlement for `com.apple.Music` to compile AppleScript calls.
- **Privacy Policy**: No clipboard or playback details will be transmitted to remote servers. All queries to fallback lyrics services (if implemented) will query by artist and song title only.
