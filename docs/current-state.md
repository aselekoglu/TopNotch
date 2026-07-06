# Current State: Top Notch

Last updated: 2026-07-06

## Summary

Task 8, "Implement Clipboard Privacy Filters", has been implemented and verified. The clipboard module now has a pure `ClipboardPrivacyFilter` and `ClipboardPolicy` boundary in `TopNotchCore` so future clipboard monitoring/storage can reject sensitive-looking text before persistence. The filter rejects credential, token/API key, 2FA/OTP, and Luhn-valid payment card-like content; enforces a configurable maximum text length; and represents excluded source apps by bundle identifier.

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
- Runs 31 unit tests successfully across shell configuration, screen calculations, registry operations, state stores, player controls, lyrics provider/state stores, and clipboard privacy filtering.

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
- `docs/technical-risks.md`: Apple Music integration risks, permissions, and lyrics feasibility document.
- `script/build_and_run.sh`: Build, bundle, launch, and verification script.

## Verification History

## Unit Tests
A new test suite `ClipboardPrivacyFilterTests` was added to verify ordinary text acceptance, credential/token/2FA/payment-card rejection, Luhn false-positive avoidance, maximum-length boundaries, and excluded source app handling.

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

Latest result:
```text
Executed 31 tests, with 0 failures (0 unexpected) in 0.592 (0.598) seconds
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

## Next Task

Task 8 is complete. The next task in the approved implementation plan is:
- Task 9: "Implement Text-Only Clipboard History Store".
  - Monitor and store accepted text clipboard entries locally with default retention of 100 items or 30 days.
