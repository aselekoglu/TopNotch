# Current State: Top Notch

Last updated: 2026-07-06

## Summary

Task 3, "Add Module Registry and Planned Module Model", has been implemented and verified. The app now includes a central thread-safe registry to manage active and planned modules, along with a dropdown dashboard panel that toggles open/closed when clicking the top surface pill.

The app currently:

- Builds a `TopNotch` executable and stages a real `dist/Top Notch.app` bundle through `script/build_and_run.sh`.
- Runs as an accessory/menu-bar utility without a Dock icon.
- Displays a status item menu with Settings and Quit actions.
- Renders a top-center floating visual pill (`NSPanel` with level `.statusBar`) on the target screen.
- Handles hover animations on the pill using a fluid spring transition in SwiftUI (compact state expands on hover).
- Aligns a dropdown dashboard panel (`NSPanel` with level `.statusBar` and frosted glass background) directly below the pill when clicked.
- Listens to global/local events to dismiss the panel when clicking outside, safeguarding against double-toggling.
- Features a registry-driven list showing active modules (Music, Clipboard, Notes) and planned modules (Calendar, Timer, File Drop, Commands, Agents) styled as coming-soon tiles.
- Runs 9 unit tests successfully across shell configuration, screen calculations, and registry operations.

## Important Files

- `Package.swift`: SwiftPM package definition.
- `Sources/TopNotchCore/AppShellConfiguration.swift`: Testable Task 1 app-shell state.
- `Sources/TopNotchCore/NotchGeometryCalculator.swift`: Testable screen positioning logic.
- `Sources/TopNotchCore/Modules/WorkflowModule.swift`: Registry module data definitions.
- `Sources/TopNotchCore/Modules/ModuleRegistry.swift`: Thread-safe registry store.
- `Sources/TopNotch/App/TopNotchApp.swift`: App entrypoint.
- `Sources/TopNotch/App/AppDelegate.swift`: AppKit lifecycle and window integration.
- `Sources/TopNotch/App/StatusItemController.swift`: Menu-bar status item.
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceWindowController.swift`: Floating pill window controller.
- `Sources/TopNotch/UI/NotchMiniDisplay/TopSurfaceView.swift`: SwiftUI pill with hover spring animations and tap callbacks.
- `Sources/TopNotch/UI/Panel/MainPanelWindowController.swift`: Dropdown window controller with auto-dismiss behavior.
- `Sources/TopNotch/UI/Panel/MainPanelView.swift`: SwiftUI dashboard with frosted glass visual effects.
- `Sources/TopNotch/UI/ModuleGrid/ModuleGridView.swift`: Grid representing active rows and planned tiles.
- `Sources/TopNotch/UI/Settings/SettingsWindowController.swift`: Settings window host.
- `Sources/TopNotch/UI/Settings/SettingsView.swift`: Settings content.
- `Tests/Unit/AppShellConfigurationTests.swift`: App shell unit tests.
- `Tests/Unit/NotchGeometryCalculatorTests.swift`: Geometry calculation unit tests.
- `Tests/Unit/ModuleRegistryTests.swift`: Registry management unit tests.
- `script/build_and_run.sh`: Build, bundle, launch, and verification script.

## Verification History

### Unit Tests
A new test suite was added for `ModuleRegistry` to verify default states, toggling, set visibility, and reordering.

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

Latest result:
```text
Executed 9 tests, with 0 failures (0 unexpected) in 0.003 (0.006) seconds
✔ Test run with 0 tests in 0 suites passed after 0.001 seconds.
```

### Staging Verification
The app bundle launch/process verification:

```bash
./script/build_and_run.sh --verify
```

Latest result:
```text
Build complete.
Process verification passed through the script.
```

### Manual Checks Completed
1. Verified clicking the pill opens the panel below it with a smooth transition.
2. Verified clicking outside the panel hides it.
3. Verified clicking the pill while the panel is visible closes it cleanly without double-toggling.
4. Verified planned modules appear grayed-out at the bottom in the "Planned" section.

## Next Task

Task 3 is complete and verified. The next task in the approved implementation plan is Phase 2: Music Hook.
- Task 4: "Investigate Apple Music now-playing and lyrics feasibility".
  - Prototype and document the supported way to detect Apple Music playback and lyrics availability.
