# Spec: Top Notch

## Objective
Build Top Notch: a native macOS utility that lives around the notch/menu-bar area and gives fast access to personal workflow modules without forcing a full app switch.

The first user is Ataberk. Productization is a later phase. The MVP should feel useful daily before it tries to be broadly marketable.

Primary hook:
- Active music mini display with lyrics.
- Show synced lyrics when available.
- Fall back to plain lyrics when available.
- Fall back to a clean "lyrics yok" state when neither is available.

Daily utility modules:
- Privacy-first local clipboard history.
- Text-only clipboard history in MVP.
- Default clipboard retention: latest 100 text items or 30 days, whichever limit applies first.
- Markdown scratchpad plus a few pinned markdown notes.
- One-click copy for notes and clipboard items.

Planned modules visible in UI as disabled/coming soon:
- Calendar
- Timer
- File drop
- Quick commands
- Agents

Phase 2 differentiator:
- Agents module for read-only monitoring of agentic development tools such as Codex, Claude Code, and Antigravity.
- Show active chats/runs/status/latest responses.
- Clicking an item opens the source chat/tool.
- No command execution, pause/resume, or new task creation in the first agent phase.

## Assumptions
1. The first build is a native macOS app, likely SwiftUI plus AppKit where needed for menu-bar, panels, accessibility, and pasteboard integration.
2. MVP is local-first and personal-use oriented: no accounts, no cloud sync, no payments, no telemetry by default.
3. The notch/menu-bar surface is the primary product surface; a normal preferences window is allowed for settings.
4. Layout, visibility, and module ordering should be configurable wherever practical.
5. MVP targets recent macOS versions only. Exact minimum version is TBD after checking the APIs needed for media detection, lyrics, notch/menu-bar behavior, and clipboard monitoring.

## Tech Stack
Recommended starting point:
- Language: Swift
- UI: SwiftUI for panels/settings, AppKit where SwiftUI cannot control the required window behavior cleanly
- App shell: macOS menu-bar app with floating notch-adjacent panel
- Persistence: local file or SQLite-backed store, TBD after prototyping clipboard/notes scale
- Secrets/privacy: no remote storage in MVP

## Visual Direction
Top Notch should feel native to modern macOS and target a macOS 27-era Liquid Glass direction.

Design principles:
- Use native macOS structures and controls first.
- Prefer system glass/material behavior over custom blur stacks or opaque fake glass.
- Use custom glass surfaces only where the app has a distinctive need: notch/virtual-island surface, live activity expansion, compact module tiles, and panel transitions.
- Keep the UI compact, premium, translucent, and useful under pointer/keyboard interaction.
- Avoid decorative glass for its own sake; glass should communicate hierarchy, state, and interactivity.
- Planned module tiles should feel intentional, not like unfinished broken features.

Primary sources to verify during implementation:
- Apple Liquid Glass technology overview: https://developer.apple.com/documentation/technologyoverviews/liquid-glass
- Apple adopting Liquid Glass overview: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

Secondary reference:
- devanshuDesai/agent-skills: https://github.com/devanshudesai/agent-skills

Do not assume specific Liquid Glass APIs until the implementation project has verified the exact macOS/Xcode SDK version.

Key technical investigations before implementation:
- Reliable active media detection for Apple Music as the first provider.
- Provider boundary that can support Spotify later without redesigning the music module.
- Official lyrics access options and limitations.
- Feasibility of synced lyrics via official APIs versus user/imported LRC or third-party metadata.
- Notch detection and positioning across notch and notchless screens.
- Clipboard monitoring constraints, private content filtering, and excluded app detection.
- Opening source chats/tools for future Agents module.

## Commands
No project exists yet. Once scaffolded, expected commands should be documented as exact commands.

Proposed native macOS shape:
```bash
# Build
xcodebuild -scheme TopNotch -configuration Debug build

# Test
xcodebuild test -scheme TopNotch -destination 'platform=macOS'

# Format/lint
swiftformat .
swiftlint
```

If we choose a Swift Package structure:
```bash
swift build
swift test
```

## Project Structure
Proposed structure:
```text
TopNotch/
  App/
    TopNotchApp.swift
    AppDelegate.swift
  Core/
    Modules/
    Persistence/
    Privacy/
    Settings/
  Modules/
    Music/
    Lyrics/
    Clipboard/
    Notes/
    Planned/
    Agents/
  UI/
    NotchMiniDisplay/
    Panel/
    ModuleGrid/
    Settings/
  Tests/
    Unit/
    Integration/
  Docs/
    spec.md
    technical-risks.md
```

## Product Surfaces
### Mini Display
Persistent, compact display near the notch/menu-bar when a live activity exists.

If the selected display has a physical notch, the mini display should visually attach to or grow from that notch area. If the selected display has no notch, the app should render a virtual Dynamic Island-like handler at the top center of the selected display.

MVP live activity:
- Active music track.
- Playback state.
- Current lyric line when synced lyrics exists.
- Compact fallback when lyrics are unavailable.

Later live activities:
- Timer
- Calendar next event
- Agent waiting for input/approval

Default interactions:
- Hover near the notch should make the app subtly react so it is clear there is an interactive surface.
- Click opens the full panel.
- When a live activity exists, hover can expand the live activity preview instead of opening the full panel.
- Hover behavior, click behavior, live-activity expansion, and keyboard shortcuts should be configurable.

### Main Panel
Opens by default on click. Optional triggers can include hover, gesture, or configurable keyboard shortcut.

MVP modules:
- Music + lyrics detail view
- Clipboard history
- Scratchpad/pinned notes

Visible disabled tiles:
- Calendar
- Timer
- File drop
- Quick commands
- Agents

Planned modules should appear in a compact "Planned" section so they communicate product direction without competing with working MVP modules.

### Settings
Must support:
- Enable/disable modules
- Reorder visible modules
- Show active and planned modules in the module list
- Mini display visibility behavior
- Hover affordance behavior
- Live activity hover expansion behavior
- Panel trigger configuration
- Clipboard exclusions and retention
- Notes persistence options
- Lyrics source/fallback preferences
- Selected display behavior for multi-monitor setups
- Notch versus virtual island behavior

## Notes Scope
MVP notes support Markdown because the user wants snippets to be lightweight but expressive.

Keep the scope narrow:
- Scratchpad accepts Markdown text.
- Pinned notes store Markdown text.
- Rendered preview is allowed.
- One-click copy should copy the source Markdown by default.
- No folders, backlinks, tags, collaboration, rich attachments, or full Apple Notes/Notion replacement behavior in MVP.

## Music Provider Scope
MVP starts with Apple Music because it matches the first user's active workflow.

Architecture should still define a provider boundary:
```swift
protocol MediaProvider {
    var displayName: String { get }
    func currentTrack() async throws -> NowPlayingTrack?
    func playbackState() async throws -> PlaybackState
}
```

Spotify is planned as a later provider, not an MVP blocker.

## Code Style
Prefer small feature modules with explicit boundaries. Avoid putting product logic directly inside SwiftUI views.

Example style:
```swift
protocol ClipboardStore {
    func recentItems(limit: Int) async throws -> [ClipboardItem]
    func save(_ item: ClipboardItem) async throws
}

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let kind: ClipboardItemKind
    let preview: String
    let createdAt: Date
    let sourceAppBundleID: String?
}
```

Conventions:
- Views render state; services own side effects.
- Module state should be testable without launching the full app.
- Privacy filters sit before persistence, not after.
- Planned modules should use the same module registry as active modules, but route to disabled UI.

## Testing Strategy
Unit tests:
- Clipboard privacy filters.
- Clipboard retention limits: latest 100 text items and 30-day default expiration.
- Text-only clipboard item handling.
- Markdown notes pin/unpin/copy behavior.
- Module registry active versus planned module state.
- Lyrics fallback selection.

Integration/manual tests:
- Active media detection with Apple Music and Spotify.
- Mini display positioning on notch and notchless screens.
- Selected-display behavior across multi-monitor setups.
- Clipboard monitoring with excluded apps and sensitive content.
- Settings changes affecting panel layout.

Manual acceptance checks for MVP:
- Start music, see mini display update.
- On a notchless selected display, confirm the mini display behaves like a virtual Dynamic Island at top center.
- If synced lyrics are available, see active lyric line update.
- If lyrics are unavailable, see clean fallback.
- Copy normal text, see it appear in clipboard history.
- Copy sensitive-looking content, verify it is not stored.
- Confirm clipboard history can be configured away from the default 100-item/30-day retention.
- Copy an image or file, verify MVP clipboard history ignores it cleanly.
- Write scratchpad text, pin it, copy it with one click.
- Confirm Markdown source can be edited and rendered preview is readable.
- Confirm disabled future modules are visible but non-interactive beyond a coming-soon state.
- Confirm planned modules appear both in the main panel and settings module list.

## Boundaries
Always:
- Keep clipboard and notes local in MVP.
- Filter sensitive clipboard content before saving.
- Keep clipboard history text-only in MVP.
- Make module visibility/config user-controlled where practical.
- Support notch and notchless selected displays intentionally.
- Treat official lyrics/API limitations as product constraints, not bugs to bypass recklessly.
- Keep Agents read-only in first agent phase.

Ask first:
- Adding cloud sync.
- Adding analytics/telemetry.
- Using third-party lyrics APIs with unclear licensing.
- Storing full chat logs from agentic tools.
- Adding global keyboard hooks beyond app shortcuts.
- Requesting accessibility permissions.
- Implementing control actions for Agents.

Never:
- Store passwords, 2FA codes, payment details, or obviously sensitive clipboard contents by default.
- Send clipboard, notes, lyrics, media, or agent data to a server in MVP.
- Build destructive agent controls into the first Agents implementation.
- Promise guaranteed synced lyrics coverage.
- Clone NotchNook branding, copy, or proprietary behavior one-to-one.

## Success Criteria
MVP is successful when:
- The app is useful daily for music/lyrics without requiring the main panel to stay open.
- Clipboard history is useful but does not feel privacy-invasive.
- Scratchpad/pinned notes are faster than opening a full notes app for temporary text.
- The app feels modular from day one, with future modules visible as part of the product direction.
- Settings provide meaningful layout/visibility control without making the first-run experience confusing.
- The app can run entirely locally.

## Open Questions
1. Working name: what should we call it internally?
2. What is the acceptable lyrics fallback source if official APIs do not provide synced lyrics?
3. What minimum macOS version are we willing to target?
