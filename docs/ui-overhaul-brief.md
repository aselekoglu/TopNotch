# TopNotch UI/UX Overhaul Brief

## Status
Draft for mockup generation and design iteration.

## Date
2026-07-06

## Purpose
Define the design intent and mockup prompt pack for the next TopNotch UI/UX overhaul. This document is the shared source for Stitch and Higgsfield experiments before implementation starts.

## Product Intent
TopNotch should feel like a native macOS feature made by Apple, not like a third-party utility or a clone of an existing notch app.

The core interaction metaphor is:

- A compact surface lives physically at the notch or top-center menu-bar area.
- The surface reacts on hover.
- The notch appears to expand seamlessly into a single native control center surface.
- The expanded surface should feel attached to the screen edge and notch, not like a detached app window, tabbed dashboard, or floating card grid.

The design should borrow the interaction grammar of Dynamic Island on iPhone 14 Pro and newer devices, adapted for macOS:

- compact idle state
- hover preview state
- expanded live/activity surface
- fluid transitions between states
- native material, depth, and hierarchy

## Current UI Problems To Avoid

- `Nook / Tray` tabs feel like prototype language and too close to NotchNook.
- The current panel reads as a separate dashboard window rather than the notch expanding.
- Repeated glass cards and hard-coded dark translucent blocks can feel cheap if overused.
- Placeholder features should not look broken or unfinished.
- Keyboard shortcut placeholder should not appear until the feature is designed and implemented.

## Product Decisions

### Music Controls
Music controls are desired long term, but not required for the immediate overhaul implementation.

For the next design round:

- Primary music surface should focus on now-playing, playback state, and lyrics/fallback.
- Play, pause, previous, and next controls can be omitted or shown only as a future/permission-gated concept.
- Do not make Apple Music control permissions part of the first-run experience.

### Live Lyrics Micro-Surface
When live/synced lyrics are available, TopNotch should be able to show a small lyrics preview directly under the notch.

Expected behavior:

- Show previous, current, and next lyric lines.
- Keep the lyric stack horizontally centered under the notch or virtual island.
- Keep the default state small, subtle, and ambient so it does not feel like a detached subtitle overlay.
- On hover, the lyric preview can grow slightly and become easier to read.
- This behavior must be configurable in settings.
- If synced lyrics are unavailable, fall back to the normal lyrics/fallback treatment in the expanded island.

### Multi-Display Behavior
The selected display is the active display.

Expected behavior:

- The active display owns the full expanded island and main interactive surface.
- On multiple displays, inactive displays still show an idle compact island.
- Hovering an inactive island can show a lightweight now-playing preview without requiring a click.
- Full panel, clipboard, notes, settings, and deeper interactions remain tied to the active display.
- Clicking an inactive island can become the later affordance to make that display active.

### Keyboard Shortcut
Global keyboard shortcut UI is out of scope for the immediate overhaul.

Rules:

- Remove the visible `Option + Space` placeholder from settings.
- Do not request global keyboard hook permissions.
- Reintroduce shortcuts only as a later phase with explicit UX and permission design.

### Planned Modules
Planned modules should be designed as if they already belong in the final product information architecture, even though they remain disabled in code until implemented.

Modules:

- Calendar
- Timer
- File Drop
- Quick Commands
- Agents

Design expectation:

- Planned modules should occupy plausible real product slots.
- Disabled states should be polished and intentional.
- Greyed-out controls are acceptable when they look like native disabled states, not unfinished placeholders.

### Agents Module
Agents should be more prominent than ordinary utility modules because it is the long-term differentiator.

Rules:

- Design Agents as a read-only activity/status feed.
- Do not include command execution, pause/resume, new task creation, approval controls, or agent control actions.
- It may have a larger or more distinctive surface than Calendar/Timer/File Drop/Quick Commands.
- It should communicate future value without implying active control.

### Layout Customization
The expanded island layout should eventually be configurable.

Immediate design scope:

- Module visibility.
- Module ordering.
- Module size or priority: compact, regular, prominent.
- Dynamic primary area driven by live activity or most recent activity.

Later design scope:

- Drag-and-drop grid editing.
- Freer spatial layout.

Do not make the first overhaul feel like a builder tool. It should feel like guided Apple-style customization.

## Design Principles

- Native macOS first.
- Premium, calm, compact, and useful.
- The expanded surface should feel physically connected to the notch.
- Prefer one coherent surface over nested cards.
- Use material, shadow, geometry, and motion to communicate hierarchy.
- Avoid marketing-page visuals, decorative blobs, heavy gradients, and generic SaaS dashboard composition.
- Avoid clone-specific naming and layout patterns from NotchNook.
- Planned modules should feel dormant, not fake.
- Text should be sparse, scannable, and native.
- Icons should feel system-native.

## Out Of Scope For Immediate Overhaul

- Cloud sync.
- Accounts.
- Telemetry or analytics.
- Payments.
- Server-side storage.
- Global keyboard hooks.
- Accessibility permission requests.
- Lyrics API permission requests.
- Agent control actions.
- Apple Music control permission onboarding.

## Required Mockup States

Generate a coherent set of related states, not unrelated single screens.

### State 1: Active Display Idle Island
Compact notch/top-center surface on the active display. It should feel alive but quiet.

Must show:

- Physical connection to notch or virtual island position.
- Minimal idle affordance.
- No full panel.

### State 2: Inactive Display Idle Island
Compact surface on a non-active display in a multi-monitor setup.

Must show:

- Clearly lower priority than the active display.
- Still polished and intentional.
- No panel or deep controls.

### State 3: Inactive Display Hover Preview
Lightweight now-playing preview when the pointer hovers over an inactive display island.

Must show:

- Track title/artist or compact now-playing cue.
- No full panel.
- No clipboard, notes, settings, or agent interactions.

### State 4: Active Expanded Island, Default Live Layout
The main expanded notch surface. It should feel like the notch grew into a native control center.

Default content priority:

- Now-playing and lyrics/fallback as the strongest live activity.
- If synced lyrics exist, a small previous/current/next lyric micro-surface can sit centered directly under the notch, with a larger hover state.
- Secondary access to Clipboard and Notes.
- Calendar, Timer, File Drop, Quick Commands in disabled but designed slots.
- Agents visible as a distinctive read-only status surface.

### State 5: Productivity-Heavy Layout
Same expanded island system, but with Clipboard and Notes prioritized over Music.

Must show:

- Configurable module priority.
- Clipboard and Notes as real daily utilities.
- Music still present but not necessarily dominant.

### State 6: Agents-Focused Layout
Expanded island with Agents as a prominent read-only activity feed.

Must show:

- Agent run/chat/status snippets.
- Read-only state.
- No command buttons.
- No pause/resume/new-task actions.

### State 7: Layout Configuration Settings
Native macOS settings view for configuring the island composition.

Must show:

- Module visibility.
- Module order.
- Size or priority choice.
- Active display selection.
- Live lyrics under-notch preview toggle and hover expansion behavior.
- No keyboard shortcut placeholder.
- Planned modules visible but disabled where appropriate.

## Shared Prompt For Stitch And Higgsfield

Use this as the base prompt for every generated state:

```text
Design a native macOS app UI called TopNotch. It should feel like Apple built it into macOS. The app lives at the physical MacBook notch or, on notchless displays, as a top-center virtual island. The key interaction is that the compact notch surface expands seamlessly into one coherent control-center-like island, similar to Dynamic Island on iPhone 14 Pro and newer devices, but adapted for macOS.

Avoid a third-party dashboard look. Avoid NotchNook clone patterns, tab bars named Nook/Tray, detached floating windows, generic glass cards, marketing visuals, decorative gradient blobs, and cheap dark translucent panels. The expanded UI must feel physically attached to the notch/top screen edge, not like a separate app window.

Use native macOS materials, subtle depth, compact typography, SF-symbol-like iconography, restrained glass, and calm hierarchy. The product is local-first and personal. No accounts, no cloud sync, no telemetry, no payments.

Core modules: Music with now playing and lyrics/fallback, Clipboard history, Markdown Notes. Planned modules should be designed as real future parts of the product but rendered disabled for now: Calendar, Timer, File Drop, Quick Commands, and Agents. Agents should be a more prominent read-only activity/status feed, with no command execution controls.

Music controls are a later phase. Do not make play/pause/next/previous the primary UI. Focus on now-playing, playback state, and lyrics/fallback.

When synced lyrics are available, include an optional small lyric micro-surface directly under the notch: previous line, current line, and next line centered under the notch or virtual island. It should be subtle by default and grow slightly on hover. This behavior should be configurable in settings.

The layout should support future customization: module visibility, order, and size/priority. Do not make it feel like a complex builder tool.
```

## State-Specific Prompts

### Active Display Idle Island

```text
Create the active display idle state for TopNotch. Show only the compact notch/top-center island. It should be quiet, premium, and native, with a subtle alive affordance. No dashboard, no tab bar, no module cards. The island should feel attached to the physical notch or screen edge.
```

### Inactive Display Hover Preview

```text
Create the inactive display hover preview state for TopNotch in a multi-monitor setup. The island is not the active display, but hovering it reveals a lightweight now-playing preview. Show track title/artist or a compact music cue. Do not show the full panel, clipboard, notes, settings, or agent controls. It should feel lower priority than the active display but still polished.
```

### Active Expanded Island, Default Live Layout

```text
Create the main active expanded island for TopNotch. The compact notch has expanded into one seamless macOS-native control center surface. Default priority is Music now-playing and lyrics/fallback, with secondary access to Clipboard and Notes. Calendar, Timer, File Drop, Quick Commands, and Agents should be placed as if part of the final product, but visually disabled where not implemented. Agents should have a distinctive read-only activity/status feed surface. No tab bar, no detached dashboard window, no Nook/Tray labels.

If synced lyrics are available, show a small centered lyric preview directly under the notch with previous/current/next lines. It should feel like an ambient extension of the notch, not a separate subtitle box. Include a hover state where the lyrics become slightly larger and easier to read.
```

### Productivity-Heavy Layout

```text
Create a configurable productivity-heavy expanded island layout for TopNotch. Clipboard and Markdown Notes are prioritized over Music, showing that module order and priority can be customized. Music remains available as a compact live module. Planned modules still exist in polished disabled states. The surface should remain one coherent notch-expanded control center.
```

### Agents-Focused Layout

```text
Create an Agents-focused expanded island layout for TopNotch. Agents is the prominent module and appears as a read-only activity/status feed for agentic development tools. Show active runs, waiting status, latest response snippets, or source tool names. Do not include command execution, pause/resume, approval, or new task controls. Other modules remain available but secondary.
```

### Layout Configuration Settings

```text
Create a native macOS settings screen for TopNotch layout configuration. It should allow module visibility, module order, module size/priority, and active display selection. Include active modules and planned modules. Do not show a global keyboard shortcut placeholder. Keep it Apple-native and calm, not a complex builder interface.

Include a Music/Lyrics setting for enabling the under-notch synced lyrics preview and configuring whether it expands on hover.
```

## Tool Comparison Criteria

Use the same prompts in Stitch and Higgsfield, then compare outputs on:

- Does it feel Apple-native rather than like a third-party utility?
- Does the notch expansion metaphor read immediately?
- Are states coherent with each other?
- Does it avoid NotchNook clone language and layout?
- Are disabled/planned modules polished?
- Is Agents visually prominent but clearly read-only?
- Can the design translate into SwiftUI/AppKit components without excessive custom rendering?
- Does it provide enough structure for an incremental implementation plan?

## Implementation Notes For Later

Before implementing the selected design direction:

- Fix selected-display runtime behavior so `targetDisplayIndex` controls actual surfaces.
- Introduce multi-display top surface management.
- Remove global keyboard shortcut placeholder from settings.
- Defer or gate Apple Music control actions behind a later permission/onboarding phase.
- Add settings for the under-notch synced lyrics micro-surface and hover expansion.
- Replace scattered hard-coded UI metrics/colors with a small local design token layer.
- Render expanded island content from a module layout model rather than fixed rows.
