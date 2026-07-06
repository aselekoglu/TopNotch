# Top Notch

Top Notch is a native macOS utility that lives around the physical notch or top-center menu bar area. It provides a compact daily workflow surface for Apple Music playback, lyrics fallback states, local clipboard history, notes, and planned read-only workflow modules without forcing a full app switch.

The current build is a personal-use MVP for Ataberk. It is local-first, Swift/SwiftUI/AppKit-based, and intentionally avoids accounts, cloud sync, telemetry, analytics, payments, and server-side storage.

## Current Status

The app currently provides:

- A top-center floating `NSPanel` surface that attaches visually to a physical notch or behaves like a virtual island on notchless displays.
- Apple Music now-playing detection through a provider boundary, with playback controls and hover expansion.
- Lyrics state handling for synced, plain, loading, and unavailable states.
- A black-core dropdown dashboard with Overview, Media, Agents, Tools, and Settings entry points.
- A three-column dashboard layout for calendar context, media playback, and clipboard history.
- Privacy-first text clipboard history with pre-persistence filtering.
- Markdown scratchpad and pinned notes storage.
- Display settings for physical notch deadzone, inactive surface size, and hover surface size, including live calibration highlighting.
- Multi-display repositioning for the floating top surface.

Planned or constrained areas:

- Agents are Phase 2 and must remain read-only when implemented.
- Calendar content in the current panel is mock/local UI context, not a calendar integration.
- Global keyboard shortcuts, accessibility automation, and extra Apple Music automation access require explicit approval before expanding.
- Official Apple Music synced lyrics are not available through public MusicKit APIs; the implementation uses provider boundaries and fallback states.

## Quick Start

Requirements:

- macOS 14 or newer.
- Xcode beta installed at `/Applications/Xcode-beta.app`.
- Swift Package Manager.

Build, bundle, and launch the app:

```bash
./script/build_and_run.sh
```

Verify the staged app bundle launches:

```bash
./script/build_and_run.sh --verify
```

Run the unit test suite:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

Do not use the default `.build` directory on this machine. The project lives in a FileProvider-managed location, and test bundle signing can fail with resource fork or Finder metadata errors. Use the `/tmp/topnotch-swiftpm-build` scratch path above.

## Commands

| Command | Purpose |
| --- | --- |
| `./script/build_and_run.sh` | Build the Swift package, stage `dist/Top Notch.app`, and launch it. |
| `./script/build_and_run.sh --verify` | Build, launch, and verify the `TopNotch` process is running. |
| `./script/build_and_run.sh --logs` | Launch and stream process logs. |
| `./script/build_and_run.sh --telemetry` | Launch and stream logs for the app subsystem. |
| `COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build` | Run all unit tests with the required scratch path. |

## Product Surfaces

### Top Surface

`TopSurfaceWindowController` owns the top-level floating panel. `TopSurfaceView` renders the live visual surface.

Behavior:

- The window sits at the top center of the active display.
- A physical notch is inferred from the screen safe-area top inset unless virtual-island mode is forced.
- Music playback can show compact or hover-expanded states.
- Physical notch deadzone settings reserve a content-free area so text and controls do not sit under the camera housing.
- Inactive and hover surface size settings control the actual view dimensions.
- Active calibration sliders highlight the corresponding surface or deadzone region.

Relevant files:

- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceWindowController.swift`
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceView.swift`
- `Sources/TopNotchCore/NotchGeometryCalculator.swift`
- `Sources/TopNotchCore/Core/Settings/NotchCalibrationHighlightStore.swift`

### Main Panel

`MainPanelWindowController` owns the dropdown dashboard window. `MainPanelView` renders the responsive black-core panel.

Behavior:

- Click the top surface to open or close the panel.
- The panel positions itself relative to the top surface frame.
- Opening Settings from the panel closes the dropdown first.
- The panel uses the screen that contains the top surface to choose notch-aware geometry.
- When lyrics are unavailable, the lower lyrics area collapses into a shallower, straight-bottom footer.

Relevant files:

- `Sources/TopNotch/UI/Panel/MainPanelWindowController.swift`
- `Sources/TopNotch/UI/Panel/MainPanelView.swift`
- `Sources/TopNotch/UI/Panel/NotchPanelShape.swift`
- `Sources/TopNotch/UI/Panel/NotchLyricsView.swift`
- `Sources/TopNotch/UI/Panel/NotchMediaPlayerColumn.swift`
- `Sources/TopNotch/UI/Panel/NotchCalendarView.swift`

### Settings

Settings are hosted in a normal AppKit window with SwiftUI content.

Display settings include:

- Physical Notch Deadzone width and height.
- Inactive View Size width and height.
- Hover View Size width and height.
- A live calibration preview.
- Active slider and region highlighting.

The compact surface defaults are:

- Physical deadzone: `180 x 24`
- Inactive surface: `420 x 64`
- Hover surface: `560 x 118`

If an older settings file contains the previous surface defaults (`600 x 88` and `720 x 150`), `SettingsStore` migrates those values to the compact defaults on load.

Relevant files:

- `Sources/TopNotch/UI/Settings/SettingsWindowController.swift`
- `Sources/TopNotch/UI/Settings/SettingsView.swift`
- `Sources/TopNotchCore/Core/Settings/AppSettings.swift`
- `Sources/TopNotchCore/Core/Settings/SettingsStore.swift`

## Modules

### Music

Music state is isolated behind provider protocols in `TopNotchCore`.

Key pieces:

- `MediaProvider` defines now-playing metadata and playback state retrieval.
- `AppleMusicProvider` is the current provider.
- `AppleMusicProbe` handles platform-specific Music.app observation.
- `MusicStateStore` publishes current track, playback state, and player position to the UI.
- `LyricsProvider` and `LyricsState` isolate lyrics lookup and fallback rendering.

Apple Music integration is intentionally defensive:

- Passive distributed notifications work without prompting.
- AppleScript queries are guarded because they can require Automation permission and can launch Music.app if misused.
- Lyrics lookup falls back cleanly when synced or plain lyrics are unavailable.

### Clipboard

Clipboard is local-only and text-only in the MVP.

Rules:

- Filtering happens before persistence.
- Sensitive-looking text is rejected before it reaches disk.
- Image and file clipboard entries are ignored.
- Retention defaults to 100 text items or 30 days.
- Copy-back actions avoid duplicate history churn.

Relevant files:

- `Sources/TopNotchCore/Modules/Clipboard/ClipboardPrivacyFilter.swift`
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardPolicy.swift`
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardStore.swift`
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardMonitor.swift`
- `Sources/TopNotch/Modules/Clipboard/ClipboardPanelView.swift`
- `Sources/TopNotch/Modules/Clipboard/ClipboardItemRow.swift`

### Notes

Notes support a narrow Markdown workflow:

- Scratchpad Markdown.
- Pinned Markdown notes.
- Markdown preview.
- Copy source Markdown.
- Local persistence only.

Relevant files:

- `Sources/TopNotchCore/Modules/Notes/NotesStore.swift`
- `Sources/TopNotchCore/Modules/Notes/Note.swift`
- `Sources/TopNotch/Modules/Notes/NotesPanelView.swift`
- `Sources/TopNotch/Modules/Notes/MarkdownPreviewView.swift`
- `Sources/TopNotch/Modules/Notes/PinnedNoteRow.swift`

### Planned Modules

The module registry includes planned modules so the UI can show product direction without enabling unsupported behavior:

- Calendar
- Timer
- File Drop
- Commands
- Agents

Agents must stay read-only in the first implementation phase. Do not add execution, pause, resume, submit, or new-task controls without explicit approval.

## Architecture

Top Notch is split into two SwiftPM targets:

- `TopNotchCore`: testable business logic, module state, settings, geometry, persistence, and platform service boundaries.
- `TopNotch`: AppKit lifecycle, windows, status item, and SwiftUI views.

High-level structure:

```text
Sources/
  TopNotch/
    App/
    Modules/
      Clipboard/
      Notes/
    UI/
      ModuleGrid/
      NotchMiniDisplay/
      Panel/
      Settings/
  TopNotchCore/
    Core/
      Settings/
    Modules/
      Clipboard/
      Music/
      Notes/
    NotchGeometryCalculator.swift
Tests/
  Unit/
docs/
tasks/
script/
```

Design principles:

- Views render state; stores and providers own side effects.
- AppKit owns windows and menu bar integration where SwiftUI is not enough.
- Core logic should be testable without launching the app.
- Privacy filters must run before persistence.
- Module visibility and ordering flow through `SettingsStore`.
- The UI should remain compact and native-feeling rather than becoming a full-screen dashboard.

## Persistence

Top Notch writes local user data under Application Support:

```text
~/Library/Application Support/TopNotch/
  settings.json
  clipboard_history.json
  notes.json
```

Persistence constraints:

- No server-side storage.
- No account system.
- No telemetry.
- No analytics.
- No cloud sync.
- Clipboard privacy filtering happens before `clipboard_history.json` is written.

## Testing

Primary test command:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

Current verified suite:

- App shell configuration.
- Music state and playback control forwarding.
- Lyrics fallback transitions.
- Clipboard privacy filter and retention behavior.
- Clipboard store persistence.
- Module registry and module settings integration.
- Notes store persistence and UI state operations.
- Settings defaults, persistence, migration, and SettingsView initialization.
- Notch geometry and top-surface content layout.

As of the latest local verification, the suite runs 73 tests with 0 failures.

## Runtime Verification

Use:

```bash
./script/build_and_run.sh --verify
```

This stages `dist/Top Notch.app`, launches it, and checks that the `TopNotch` process is running.

Manual checks that still matter:

- Play/pause/skip in Apple Music and verify the top surface updates.
- Hover the top surface on a notched display and confirm deadzone content is not hidden by the camera housing.
- Move pointer between displays and confirm the surface follows the active display.
- Open Settings and adjust the three Display calibration groups.
- Copy ordinary text and confirm it appears in clipboard history.
- Copy sensitive-looking text and confirm it is rejected.
- Write Markdown in Notes, preview it, pin it, copy it, and relaunch.

## Development Notes for Agents

Before editing this repo, read:

1. `docs/spec.md`
2. `docs/implementation-plan.md`
3. `tasks/todo.md`
4. `docs/current-state.md`

Repo rules:

- Keep scope to the approved MVP.
- Do not add cloud sync, accounts, telemetry, analytics, payments, or server-side storage.
- Do not request accessibility, automation, global keyboard hook, or lyrics API access without asking first.
- Clipboard privacy filters must run before persistence, not after.
- Agents are Phase 2 and read-only when implemented later.
- Prefer native macOS implementation with Swift, SwiftUI, and AppKit where needed.
- Verify each task before moving to the next.

Useful docs:

- `docs/spec.md`: product intent and MVP boundaries.
- `docs/implementation-plan.md`: phase breakdown and architecture decisions.
- `docs/current-state.md`: snapshot of implemented surfaces and important files.
- `docs/technical-risks.md`: Apple Music, lyrics, sandboxing, and implementation risks.
- `tasks/todo.md`: task-level acceptance criteria.

## Git Hygiene

Use small, reviewable commits. Keep generated build output out of git:

- Do not commit `dist/`.
- Do not commit `.build/`.
- Do not commit `.swiftpm/`.
- Do not commit `.DS_Store`.

Before committing code changes, run:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
./script/build_and_run.sh --verify
```

For docs-only changes, a README diff review is usually sufficient unless the docs are packaged or generated by build tooling.
