# Implementation Plan: Top Notch

## Overview
Build Top Notch: a native macOS notch/menu-bar workflow utility for personal daily use. MVP focuses on Apple Music mini display with lyrics fallback, privacy-first text clipboard history, and Markdown scratchpad/pinned notes. Future modules are visible as planned tiles, with Agents positioned as the Phase 2 differentiator.

Source spec: `outputs/notch-workflow-app-spec.md`

## Product Flow
1. App launches as a menu-bar/native background utility.
2. User hovers near notch/top-center area.
3. The surface subtly reacts to show it is interactive.
4. If music live activity exists, hover expands the mini display.
5. User clicks the surface to open the full panel.
6. Panel shows active modules first:
   - Music + lyrics
   - Clipboard
   - Notes
7. Panel shows a compact Planned section:
   - Calendar
   - Timer
   - File Drop
   - Quick Commands
   - Agents
8. Settings controls module visibility/order, interaction behavior, clipboard retention/exclusions, notes behavior, music provider settings, and selected display behavior.

## Architecture Decisions
- Native macOS first: Swift + SwiftUI, with AppKit for status item, floating windows/panels, display positioning, and system integrations.
- Visual direction: native macOS with a macOS 27-era Liquid Glass feel. Use system structures/materials first; reserve custom glass for the notch/virtual-island surface, live activity expansion, compact module tiles, and panel transitions.
- Module registry from day one: active and planned modules use one registry so future modules do not require redesigning navigation.
- Provider boundary for music: Apple Music is first implementation; Spotify remains a later provider.
- Local-first persistence: clipboard and notes stay on device; no account, sync, or telemetry in MVP.
- Privacy filter before persistence: clipboard filtering must run before any item is stored.
- Interaction model is configurable: default hover affordance, click-to-open, live-activity hover expansion, optional shortcut later.
- Notch and notchless are both first-class: no notch means virtual Dynamic Island-like handler at top center of selected display.

## Dependency Graph
```text
App shell and window positioning
  -> Module registry
      -> Planned module tiles
      -> Music module
          -> Apple Music provider investigation
          -> Lyrics fallback strategy
      -> Clipboard module
          -> Privacy filters
          -> Local retention store
      -> Notes module
          -> Markdown storage
          -> Rendered preview/copy behavior
  -> Settings
      -> Interaction config
      -> Module config
      -> Clipboard config
      -> Display config
```

## Phase 1: Foundation
- [ ] Task 1: Scaffold native macOS app shell
- [ ] Task 2: Build notch/virtual-island window positioning prototype
- [ ] Task 3: Add module registry and planned module model

### Checkpoint: Foundation
- [ ] App builds and launches as a macOS utility.
- [ ] A top-center/notch-adjacent surface can be shown and clicked.
- [ ] Active and planned modules render from shared registry data.

## Phase 2: Music Hook
- [ ] Task 4: Investigate Apple Music now-playing and lyrics feasibility
- [ ] Task 5: Implement Apple Music provider boundary and now-playing state
- [ ] Task 6: Implement mini display and music detail panel
- [ ] Task 7: Implement lyrics fallback states

### Checkpoint: Music
- [ ] Playing Apple Music track appears in mini display.
- [ ] Hover expands live activity.
- [ ] Full panel shows track and lyrics/fallback state.
- [ ] App handles unavailable lyrics cleanly.

## Phase 3: Daily Utilities
- [ ] Task 8: Implement clipboard privacy filters
- [ ] Task 9: Implement text-only clipboard history store
- [ ] Task 10: Implement clipboard panel UI
- [ ] Task 11: Implement Markdown scratchpad and pinned notes store
- [ ] Task 12: Implement notes panel UI with preview and one-click copy

### Checkpoint: Utilities
- [ ] Normal copied text appears in history.
- [ ] Sensitive-looking text does not persist.
- [ ] Image/file clipboard entries are ignored.
- [ ] Markdown notes can be edited, previewed, pinned, and copied.

## Phase 4: Configuration and Polish
- [ ] Task 13: Implement settings model and persistence
- [ ] Task 14: Implement interaction/display settings UI
- [ ] Task 15: Implement module settings and planned tiles polish
- [ ] Task 16: Add MVP verification pass and docs update

### Checkpoint: MVP Review
- [ ] Build and tests pass.
- [ ] Manual acceptance flow from the spec passes.
- [ ] Open technical risks are documented.
- [ ] Ready for implementation review before productization decisions.

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Official synced lyrics access may be unavailable or restricted | High | Investigate before implementing full lyrics UI; design clean fallback states |
| Apple Music now-playing data may require scripting/accessibility/automation permissions | High | Prototype first; ask before requesting sensitive permissions |
| Floating notch UI may behave differently across displays/spaces/full-screen apps | High | Build positioning prototype before modules |
| Clipboard history can feel privacy-invasive | High | Filter before persistence; local-only; default retention limits; clear exclusions |
| Settings can become too complex early | Medium | Ship useful defaults; expose advanced config progressively |
| Planned tiles can make MVP feel unfinished | Medium | Keep them compact under a Planned section |
| Agents module could expand scope dramatically | High | Keep read-only and Phase 2; MVP only shows planned tile |
| Liquid Glass APIs/design guidance may depend on exact SDK/macOS version | Medium | Verify Apple docs and local SDK before using specific modifiers; design should degrade to native macOS materials if needed |

## Parallelization Opportunities
- After Task 3, planned module tile UI and individual feature panels can be designed in parallel.
- After clipboard filter contracts are defined, clipboard UI and retention tests can move in parallel.
- Notes module can proceed mostly independently after persistence conventions are chosen.

## Open Questions
- Minimum macOS version after API investigation.
- Exact Apple Music/lyrics implementation path.
- Internal product name.
- Whether to add a global keyboard shortcut in MVP or leave it for post-MVP.
- Whether to support manual LRC import as the first synced lyrics fallback.
- Exact Liquid Glass API availability in the selected Xcode/macOS SDK.
