# Antigravity Handoff: TopNotch UI/UX Mockups With Higgsfield

## Date
2026-07-06

## Goal
Continue the TopNotch UI/UX overhaul mockup phase from Antigravity, where Higgsfield MCP is connected and usable.

The immediate goal is to generate design mockups from the shared prompt pack, compare Higgsfield against Stitch, and produce a short recommendation for the implementation direction.

## Repo Context
Repo:

```text
/Users/aselekoglu/Documents/TopNotch
```

Primary brief:

```text
docs/ui-overhaul-brief.md
```

That file is the source of truth for:

- Product intent.
- UI/UX constraints.
- Required mockup states.
- Shared prompt for Stitch and Higgsfield.
- State-specific prompts.
- Tool comparison criteria.
- Later implementation notes.

## Key Product Decisions Already Made

- TopNotch should feel like a native Apple/macOS feature, not a third-party utility.
- The core metaphor is a physical notch expanding seamlessly into one coherent control-center surface.
- Avoid `Nook / Tray`, NotchNook clone language, detached dashboards, generic glass card grids, and cheap translucent panels.
- Music controls are desired long term, but should be deferred for now.
- Immediate music focus: now-playing, playback state, synced/plain/unavailable lyrics.
- When synced lyrics exist, show previous/current/next lyric lines centered under the notch as a small ambient micro-surface; on hover, lyrics can grow slightly. This must be configurable.
- Selected display is the active display.
- In multi-display setups, inactive displays still show idle islands; inactive hover can show lightweight now-playing preview without opening the full panel.
- Global keyboard shortcut placeholder should be removed from scope for now.
- Planned modules should be designed as if they are real final product modules, but implemented disabled until ready.
- Agents should be prominent and distinctive, but read-only. No command execution, pause/resume, new task, approval, or agent control actions.
- Layout should eventually support customization. Immediate scope is module visibility, ordering, and size/priority. Drag/drop grid editing is future scope.

## Higgsfield State From Codex

Codex tried the official Higgsfield CLI path:

```bash
npm install -g @higgsfield/cli
higgsfield auth login
npx skills add higgsfield-ai/skills
```

Result:

- `@higgsfield/cli@1.1.5` installed.
- Auth succeeded.
- Workspace was selected.
- Skills were installed into `.agents/skills/`.
- CLI generation failed with:

```text
only_mcp_usage_on_trial_is_available
```

Codex MCP connector attempt also hit OAuth redirect mismatch:

```json
{
  "error": "invalid_request",
  "error_description": "The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than once, or is otherwise malformed. The 'redirect_uri' parameter does not match any of the OAuth 2.0 Client's pre-registered redirect urls."
}
```

Therefore, continue from Antigravity where Higgsfield MCP is connected.

## Stitch State From Codex

A Stitch project was created:

```text
Title: TopNotch UI Overhaul
Project ID: 18370213989566646355
```

No finalized Stitch screen generation was completed before the handoff.

## Antigravity Instructions

1. Read `docs/ui-overhaul-brief.md` completely.
2. Use Higgsfield MCP to generate mockups for the required states in the brief.
3. Start with the most important state:
   - `State 4: Active Expanded Island, Default Live Layout`
4. Then generate:
   - Active Display Idle Island
   - Inactive Display Hover Preview
   - Productivity-Heavy Layout
   - Agents-Focused Layout
   - Layout Configuration Settings
5. Keep each output tied to the exact prompt/state that generated it.
6. Save image URLs, local exports, or screenshots in a durable place if possible.
7. Evaluate each result using the comparison criteria in `docs/ui-overhaul-brief.md`.
8. Produce a concise recommendation:
   - Which mockup direction is closest?
   - What should be kept?
   - What should be rejected?
   - What implementation slices should come first?

## First Higgsfield Prompt To Run

Use this first. It is copied from the active expanded island intent and adapted for direct image generation:

```text
Design a native macOS app UI mockup called TopNotch. It should feel like Apple built it into macOS. The app lives at the physical MacBook notch or, on notchless displays, as a top-center virtual island.

Show the main active expanded island: the compact notch has expanded seamlessly into one coherent control-center-like island, similar to Dynamic Island on iPhone 14 Pro and newer devices, but adapted for macOS. The expanded UI must feel physically attached to the notch/top screen edge, not like a separate app window.

Avoid NotchNook clone patterns, Nook/Tray tabs, detached dashboard windows, generic glass cards, marketing visuals, decorative gradient blobs, and cheap dark translucent panels.

Use native macOS materials, subtle depth, compact typography, SF-symbol-like iconography, restrained glass, and calm hierarchy.

Core modules: Music with now playing and lyrics/fallback, Clipboard history, Markdown Notes. Planned modules should be placed as real future parts of the final product but visually disabled: Calendar, Timer, File Drop, Quick Commands, and Agents.

Agents should be prominent as a read-only activity/status feed, with no command execution controls.

Music controls are later phase; do not make play/pause/next/previous primary. Focus on now-playing, playback state, and lyrics/fallback.

If synced lyrics are available, show a small centered lyric preview directly under the notch with previous/current/next lines. It should feel like an ambient extension of the notch, not a separate subtitle box; include a hover-expanded feel where lyrics are slightly larger and easier to read.

The layout should imply future customization: module visibility, order, and size/priority, but not a complex builder tool.

Create a polished 16:9 macOS UI design mockup on a MacBook screen, dark native material, premium Apple-like control center aesthetic.
```

Suggested settings if the tool exposes them:

```text
model: GPT Image 2 or highest-quality UI/image model
aspect ratio: 16:9
quality: high
resolution: 2k or higher
```

## Success Criteria

The handoff is successful when there is a small set of generated mockups plus a recommendation that answers:

- Does the design feel Apple-native?
- Does the notch expansion metaphor work?
- Is it clearly not a NotchNook clone?
- Are planned modules integrated as real future modules?
- Is Agents prominent but read-only?
- Does the under-notch synced lyrics micro-surface work visually?
- Can this be translated into SwiftUI/AppKit incrementally?

