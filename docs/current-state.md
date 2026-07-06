# Current State: Top Notch

Last updated: 2026-07-06

## Summary

Tasks 8, 9, 10, 11, and 13 are implemented and verified at the code/build level. The daily utilities and core features now include:
- A pure `ClipboardPrivacyFilter` + `ClipboardPolicy` boundary that rejects credential, token/API key, 2FA/OTP, and Luhn-valid payment card-like content before persistence.
- A text-only local clipboard history store (`ClipboardStore`) with retention defaults of latest 100 items or 30 days, bound dynamically to settings.
- A clipboard monitor (`ClipboardMonitor`) that polls `NSPasteboard.general` and forwards only string content to the store while ignoring image/file types.
- A compact Clipboard panel UI that renders recent text items, supports search, copies an item back to the system pasteboard, and shows clear empty/privacy-filtered states.
- A local Markdown notes store (`NotesStore`) for scratchpad content and pinned Markdown notes, with pin/update/unpin/delete persistence, bound dynamically to settings.
- A global `AppSettings` and `SettingsStore` for local preferences persistence (stored under Application Support).

The app currently:

- Builds a `TopNotch` executable and stages a real `dist/Top Notch.app` bundle through `script/build_and_run.sh`.
- Runs as an accessory/menu-bar utility without a Dock icon.
- Displays a status item menu with Settings and Quit actions.
- Renders a top-center floating visual pill (`NSPanel` with level `.statusBar`) on the target screen.
- Dynamically expands the pill's dimensions and shows track info (`🎵 Title - Artist`) during music playback.
- Displays a Live Activity mini-player card on hover during playback, supporting previous/next and play/pause controls.
- Aligns a dropdown dashboard panel (`NSPanel` with level `.statusBar` and frosted glass background) directly below the pill when clicked.
- Listens to global/local events to dismiss the panel when clicking outside, safeguarding against double-toggling.
- Features a registry-driven list showing active modules (Music, Clipboard, Notes) and planned modules (Calendar, Timer, File Drop, Commands, Agents) styled as coming-soon tiles.
- Incorporates an interactive full player card for the Music module within the main panel, now supporting metadata non-truncation constraints and an expandable lyrics viewer.
- Runs 65 unit tests successfully across shell configuration, screen calculations, registry operations, state stores, player controls, lyrics provider/state stores, clipboard privacy/history behavior, notes persistence, and settings store.

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
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceView.swift`: SwiftUI pill with hover spring animations, playback state bindings, and expanded Live Activity widgets.
- `Sources/TopNotch/UI/Panel/MainPanelWindowController.swift`: Dropdown window controller with auto-dismiss behavior.
- `Sources/TopNotch/UI/Panel/MainPanelView.swift`: SwiftUI dashboard with frosted glass visual effects.
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
- `docs/technical-risks.md`: Apple Music integration risks, permissions, and lyrics feasibility document.
- `script/build_and_run.sh`: Build, bundle, launch, and verification script.

## Verification History

## Unit Tests
The clipboard domain now has two test suites:
- `ClipboardPrivacyFilterTests` verifies ordinary text acceptance, credential/token/2FA/payment-card rejection, Luhn false-positive avoidance, maximum-length boundaries, and excluded source app handling.
- `ClipboardStoreTests` verifies accepted text storage, sensitive text rejection before persistence, retention trimming by count/age, persistence roundtrips, clear/remove operations, rejection state publishing, and duplicate copy-back suppression.
- `NotesStoreTests` verifies scratchpad Markdown persistence, pin/update/unpin/delete persistence, pinned note ordering and limits, missing-file startup, and roundtrip persistence.
- `SettingsStoreTests` verifies settings defaults, update publishers, custom path persistence roundtrips, and defaults reset.

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build-orchestrator
```

Latest result:
```text
Executed 65 tests, with 0 failures (0 unexpected) in 0.688 (0.697) seconds
✔ Test run with 0 tests in 0 suites passed after 0.001 seconds.
```

### Staging Verification
The app bundle launch/process verification:

```bash
TOPNOTCH_SWIFTPM_SCRATCH_PATH=/tmp/topnotch-swiftpm-run-build ./script/build_and_run.sh --verify
```

Latest result:
```text
Build complete.
Process verification passed through the script.
```

### Manual Checks Completed
1. Verified pill expands to a wider shape showing `🎵 Title - Artist` when music is playing.
2. Verified pill expands downwards on hover to show song details, mini artwork, and media controls.
3. Verified clicking play/pause/skip on both the mini-player and main panel detailed widget commands Apple Music correctly.
4. Verified main panel displays a detailed player card for the Music module.
5. Verified lyrics bubble button expands/collapses the player card to display plain, synced, loading, or unavailable lyrics correctly and beautifully.
6. Verified main panel sizes and corner curves (28pt) are optimized so that the artwork, buttons, and settings/mirror circle buttons are never clipped by the corners.
7. Verified notes panel write (plain text markdown editor) and read (native AttributedString styled preview) modes render and persist scratchpad markdown correctly.
8. Verified notes pinning horizontal list, copying notes raw source markdown, and unpinning/deleting notes function end-to-end.

### Manual Checks Pending
1. Clipboard panel end-to-end UI check: copy text, open panel, copy a history item back, and confirm it does not duplicate in history.

## Next Task

Task 13 is complete. The next task in the approved implementation plan is:
- Task 14: "Implement Interaction and Display Settings UI".
  - Add settings for hover affordance, click behavior, live-activity expansion, keyboard shortcut placeholder, selected display, and notch/virtual-island behavior.
