# Top Notch

Top Notch is a native macOS utility that turns the notch or top-center menu bar area into a compact workflow surface.

It is built for quick, glanceable actions: see what is playing, follow lyrics when available, open a small dashboard, reuse recent clipboard text, and keep lightweight Markdown notes nearby without switching into a full app.

The project is currently a personal-use MVP. It is local-first by design: no accounts, no cloud sync, no telemetry, no analytics, no payments, and no server-side storage.

## What It Does

- Shows a floating top-center surface around the physical notch, or a virtual island on notchless displays.
- Displays Apple Music now-playing state with playback controls and hover expansion.
- Handles lyrics as a best-effort experience: synced lyrics, plain lyrics, loading, unavailable, and clean fallback states.
- Opens a compact dashboard with media, clipboard, notes, and local context widgets.
- Stores text-only clipboard history locally after privacy filtering.
- Keeps a Markdown scratchpad and pinned Markdown notes on device.
- Provides display calibration settings for notch deadzone and surface sizing.

## Why This Exists

macOS has a lot of small workflow fragments: the song you are listening to, text you copied a minute ago, quick notes, timers, calendar context, and development tools that need attention.

Top Notch explores a narrow product idea: make the top of the screen useful without becoming another full workspace. The MVP focuses on daily personal utility first, then leaves room for planned modules later.

## Current State

Implemented:

- Native Swift, SwiftUI, and AppKit app shell.
- Menu-bar/accessory-style app behavior.
- Floating notch/virtual-island surface.
- Click-to-open dropdown panel.
- Apple Music provider boundary and now-playing state.
- Playback controls.
- Lyrics fallback model and UI states.
- Privacy-first clipboard history.
- Markdown notes storage and notes UI.
- Local settings persistence.
- Multi-display positioning.
- Unit tests for core stores, settings, modules, lyrics, clipboard, and geometry.

Planned but intentionally constrained:

- Calendar, Timer, File Drop, Quick Commands, and Agents are visible as product-direction modules.
- Calendar content in the current panel is local/mock context, not a real calendar integration.
- Agents are Phase 2 and must be read-only when implemented.
- No agent execution, pause/resume, submit, publish, or new-task controls are part of the MVP.

## Screens and Surfaces

### Top Surface

The top surface is the always-nearby entry point. It sits at the top center of the active display, accounts for a physical notch when present, and can expand on hover while music is active.

### Dashboard Panel

Clicking the top surface opens a compact dashboard below it. The current panel includes media playback, lyrics, clipboard history, local calendar-style context, notes, and settings entry points.

### Settings

Settings are local and focused on the current MVP:

- Physical notch deadzone width and height.
- Inactive top-surface size.
- Hover top-surface size.
- Live calibration preview.
- Module visibility and ordering.
- Clipboard and notes behavior.

## Privacy Model

Top Notch is local-first.

- Clipboard history is text-only.
- Sensitive-looking clipboard text is rejected before it is written to disk.
- Images and files on the clipboard are ignored.
- Default clipboard retention is the latest 100 text items or 30 days.
- User data is stored under `~/Library/Application Support/TopNotch/`.
- The app does not use server-side storage, accounts, analytics, telemetry, or cloud sync.

Local files:

```text
~/Library/Application Support/TopNotch/
  settings.json
  clipboard_history.json
  notes.json
```

## Tech Stack

- Swift
- SwiftUI
- AppKit
- Swift Package Manager
- Local JSON persistence for MVP data

The package is split into:

- `TopNotchCore`: testable business logic, settings, module state, geometry, persistence, and provider boundaries.
- `TopNotch`: AppKit lifecycle, windows, status item, and SwiftUI views.

## Quick Start

Requirements:

- macOS 14 or newer.
- Xcode beta installed at `/Applications/Xcode-beta.app`.
- Swift Package Manager.

Build, bundle, and launch:

```bash
./script/build_and_run.sh
```

Build, launch, and verify the app process:

```bash
./script/build_and_run.sh --verify
```

Run tests:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

This project should not use the default workspace `.build` path on this machine. It lives in a FileProvider-managed location, and test bundle codesigning can fail with resource fork or Finder metadata errors. Use the `/tmp/topnotch-swiftpm-build` scratch path above.

## Repository Map

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
      System/
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

Useful docs:

- `docs/spec.md`: product intent and MVP boundaries.
- `docs/implementation-plan.md`: phase breakdown and architecture decisions.
- `docs/current-state.md`: latest implemented-state snapshot.
- `docs/technical-risks.md`: Apple Music, lyrics, sandboxing, and implementation risks.
- `tasks/todo.md`: task-level acceptance criteria.

## Development Commands

| Command | Purpose |
| --- | --- |
| `./script/build_and_run.sh` | Build the Swift package, stage `dist/Top Notch.app`, and launch it. |
| `./script/build_and_run.sh --verify` | Build, launch, and verify that the `TopNotch` process is running. |
| `./script/build_and_run.sh --logs` | Launch and stream process logs. |
| `./script/build_and_run.sh --telemetry` | Launch and stream logs for the app subsystem. |
| `COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build` | Run the unit test suite with the required scratch path. |

## Contributor Notes

Keep the MVP narrow:

- Do not add cloud sync, accounts, telemetry, analytics, payments, or server-side storage.
- Do not request accessibility, automation, global keyboard hook, or lyrics API access without explicit approval.
- Keep clipboard privacy filtering before persistence.
- Keep future Agents functionality read-only unless the project scope changes.
- Prefer boring native macOS implementation with Swift, SwiftUI, and AppKit where needed.

Before code changes, read:

1. `docs/spec.md`
2. `docs/implementation-plan.md`
3. `tasks/todo.md`
4. `docs/current-state.md`

For docs-only changes, a README diff review is usually enough. For code changes, run:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
./script/build_and_run.sh --verify
```

Do not commit generated build output such as `dist/`, `.build/`, `.swiftpm/`, or `.DS_Store`.
