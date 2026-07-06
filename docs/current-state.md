# Current State: Top Notch

Last updated: 2026-07-06

### Summary
 
Tasks 1 through 15 are implemented and verified at the code/build/test level. The entire UI/UX has been overhauled to match the custom paper sketch drawing:
- A custom `NotchPanelShape` that curves around the physical camera notch at the top, and extends downward in the center as a U-shaped tab to host the synced lyrics.
- Main expanded panel uses a 3-column layout:
  - Column 1: `NotchCalendarView` showing the current week timeline and upcoming mock events.
  - Column 2: `NotchMediaPlayerColumn` with larger artwork, track details, playback controls, and a synchronized real-time progress slider.
  - Column 3: `ClipboardPanelView` showing recent clipboard items and search.
- Navigation tabs at the top:
  - Left side: "Overview" and "Media".
  - Right side: "Agents" and "Tools".
  - Rightmost: Settings gear icon.
- Synced lyrics stack (`NotchLyricsView`) shown inside the U-shaped tab at the bottom of the panel, showing previous, active (bold), and next lyric lines.
- Compact now-playing state in `TopSurfaceView` updated to show the 3 lines of lyrics directly under the notch, with the compact album badge on the left and visual equalizer waves on the right.
- App continues to build as an accessory/menu-bar utility without a Dock icon, with preferences stored locally under Application Support.
 
The app currently:
 
- Builds a `TopNotch` executable and stages a real `dist/Top Notch.app` bundle through `script/build_and_run.sh`.
- Renders the new top-center floating visual pill (`NSPanel` with level `.statusBar`) on the target screen.
- Dynamically expands the pill's height and shows compact scrolling lyrics during playback.
- Aligns the updated 840x260 dropdown dashboard panel (`NSPanel` with level `.statusBar` and frosted glass background) directly below the pill when clicked.
- Runs 69 unit tests successfully across all modules, layouts, settings, and stores.

## Important Files

- `Package.swift`: SwiftPM package definition.
- `Sources/TopNotchCore/AppShellConfiguration.swift`: Testable Task 1 app-shell state.
- `Sources/TopNotchCore/NotchGeometryCalculator.swift`: Testable screen positioning logic.
- `Sources/TopNotchCore/Modules/Music/NowPlayingTrack.swift`: Track metadata definition.
- `Sources/TopNotchCore/Modules/Music/PlaybackState.swift`: Playback state enumeration.
- `Sources/TopNotchCore/Modules/Music/MediaProvider.swift`: Media provider protocol contract.
- `Sources/TopNotchCore/Modules/Music/AppleMusicProbe.swift`: Platform now-playing bridge utility.
- `Sources/TopNotchCore/Modules/Music/AppleMusicProvider.swift`: MediaProvider wrapper around the Apple Music probe.
- `Sources/TopNotchCore/Modules/Music/LyricsState.swift`: Lyrics state and line models.
- `Sources/TopNotchCore/Modules/Music/LyricsProvider.swift`: Provider protocol contract.
- `Sources/TopNotchCore/Modules/Music/AppleMusicLyricsProvider.swift`: Provider implementing AppleScript lyrics extraction.
- `Sources/TopNotchCore/Modules/Music/MusicStateStore.swift`: MainActor state store/publisher.
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardPolicy.swift`: Clipboard capture policy for size limits and excluded source apps.
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardPrivacyFilter.swift`: Pure pre-persistence privacy filter for sensitive-looking clipboard text.
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardEntry.swift`: Codable clipboard entry model for persisted text history.
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardStore.swift`: MainActor local clipboard history store with filter-first writes and retention enforcement.
- `Sources/TopNotchCore/Modules/Clipboard/ClipboardMonitor.swift`: AppKit monitor polling `NSPasteboard` and forwarding accepted text entries.
- `Sources/TopNotch/Modules/Clipboard/ClipboardPanelView.swift`: Clipboard panel UI with search, empty/privacy-filtered states, and copy-back action.
- `Sources/TopNotch/Modules/Clipboard/ClipboardItemRow.swift`: Clipboard history row with preview, timestamp/source metadata, and copy affordance.
- `Sources/TopNotchCore/Modules/Notes/Note.swift`: Codable pinned Markdown note model.
- `Sources/TopNotchCore/Modules/Notes/NotesStore.swift`: MainActor local notes store for scratchpad and pinned note persistence.
- `Sources/TopNotchCore/Modules/WorkflowModule.swift`: Registry module data definitions.
- `Sources/TopNotchCore/Modules/ModuleRegistry.swift`: Thread-safe registry store.
- `Sources/TopNotch/App/TopNotchApp.swift`: App entrypoint.
- `Sources/TopNotch/App/AppDelegate.swift`: AppKit lifecycle and window integration.
- `Sources/TopNotch/App/StatusItemController.swift`: Menu-bar status item.
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceWindowController.swift`: Floating pill window controller.
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceView.swift`: SwiftUI pill with hover spring animations, playback state bindings, and compact lyrics.
- `Sources/TopNotch/UI/Panel/MainPanelWindowController.swift`: Dropdown window controller with auto-dismiss behavior and updated 840x260 frame.
- `Sources/TopNotch/UI/Panel/MainPanelView.swift`: SwiftUI dashboard with custom flared-notch shape and 3 columns.
- `Sources/TopNotch/UI/Panel/NotchPanelShape.swift`: Custom SwiftUI Shape for the U-shaped panel.
- `Sources/TopNotch/UI/Panel/NotchCalendarView.swift`: Mock Calendar widget.
- `Sources/TopNotch/UI/Panel/NotchMediaPlayerColumn.swift`: Custom media player widget column.
- `Sources/TopNotch/UI/Panel/NotchLyricsView.swift`: Mini lyrics stack for the U-tab.
- `Sources/TopNotch/UI/ModuleGrid/ModuleGridView.swift`: Grid representing active rows, custom widgets, and planned tiles.
- `Sources/TopNotch/UI/ModuleGrid/MusicWidgetView.swift`: Detailed music player layout for the main panel, featuring the lyrics card expansion.
- `Sources/TopNotch/UI/Settings/SettingsWindowController.swift`: Settings window host.
- `Sources/TopNotch/UI/Settings/SettingsView.swift`: Settings content.
- `Tests/Unit/AppShellConfigurationTests.swift`: App shell unit tests.
- `Tests/Unit/NotchGeometryCalculatorTests.swift`: Geometry calculation unit tests.
- `Tests/Unit/ModuleRegistryTests.swift`: Registry management unit tests.
- `Tests/Unit/MusicStateStoreTests.swift`: Music state publisher and provider mock tests.
- `Tests/Unit/MediaControlTests.swift`: Unit tests for playback controls forwarding.
- `Tests/Unit/LyricsStateStoreTests.swift`: Unit tests for lyrics provider and state transitions.
- `Tests/Unit/ClipboardPrivacyFilterTests.swift`: Unit tests for sensitive content, size limits, and excluded source apps.
- `Tests/Unit/ClipboardStoreTests.swift`: Unit tests for storage, retention, text-only behavior, and persistence roundtrips.
- `Sources/TopNotchCore/Core/Settings/AppSettings.swift`: App settings model definitions.
- `Sources/TopNotchCore/Core/Settings/SettingsStore.swift`: Settings store manager for disk persistence.
- `Tests/Unit/NotesStoreTests.swift`: Unit tests for scratchpad persistence, pin/update/unpin/delete behavior, pinned note limits, and persistence roundtrips.
- `Tests/Unit/SettingsStoreTests.swift`: Unit tests for setting defaults and persistence.
- `Tests/Unit/SettingsUIIntegrationTests.swift`: Unit/integration tests for SettingsView rendering and SettingsStore integration.
- `Tests/Unit/ModuleSettingsIntegrationTests.swift`: Unit/integration tests for active module visibility toggling, direct setting, and reordering.
- `docs/technical-risks.md`: Apple Music integration risks, permissions, and lyrics feasibility document.
- `script/build_and_run.sh`: Build, bundle, launch, and verification script.

## Verification History

### Unit Tests
Executed 69 tests with 0 failures (0 unexpected) successfully.

### Staging Verification
The app bundle launch/process verification:
```bash
TOPNOTCH_SWIFTPM_SCRATCH_PATH=/tmp/topnotch-swiftpm-run-build-orchestrator ./script/build_and_run.sh --verify
```
Result:
```text
Build complete.
Process verification passed through the script.
```
