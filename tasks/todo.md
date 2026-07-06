# Task List: Top Notch MVP

## Task 1: Scaffold Native macOS App Shell
**Description:** Create the initial Swift/SwiftUI macOS project structure for a menu-bar/background utility with a preferences-capable app shell.

**Acceptance criteria:**
- [ ] App builds and launches on macOS.
- [ ] App can run without showing a normal main window by default.
- [ ] Preferences/settings window can be opened.
- [ ] Project/scheme/app naming uses Top Notch or `TopNotch` consistently where spaces are not practical.

**Verification:**
- [ ] Build succeeds with the chosen project command.
- [ ] Manual check: launch app, confirm utility-style behavior.

**Dependencies:** None

**Files likely touched:**
- `NotchWorkflowApp/App/NotchWorkflowApp.swift`
- `NotchWorkflowApp/App/AppDelegate.swift`
- `NotchWorkflowApp/UI/Settings/SettingsView.swift`

**Estimated scope:** M

## Task 2: Build Notch/Virtual-Island Positioning Prototype
**Description:** Implement the top surface window/panel that anchors to a physical notch when available or renders as a virtual Dynamic Island-like handler on notchless selected displays.

**Acceptance criteria:**
- [x] A compact top-center surface appears on the selected display.
- [x] Surface supports notch and notchless positioning behavior.
- [x] Surface can react subtly on hover.
- [x] Visual treatment follows native macOS/Liquid Glass direction without hard-coding unverified SDK-specific APIs.

**Verification:**
- [x] Manual check on available display setup.
- [x] Unit tests for positioning calculations where practical.

**Dependencies:** Task 1

**Files likely touched:**
- `NotchWorkflowApp/UI/NotchMiniDisplay/TopSurfaceWindowController.swift`
- `NotchWorkflowApp/UI/NotchMiniDisplay/TopSurfaceView.swift`
- `NotchWorkflowApp/Core/Settings/DisplaySelection.swift`

**Estimated scope:** M

## Task 3: Add Module Registry and Planned Module Model
**Description:** Define the module system used by both active modules and planned/disabled modules.

**Acceptance criteria:**
- [x] Active and planned modules are represented by the same registry model.
- [x] Planned modules render as disabled/coming-soon tiles.
- [x] Module order and visibility can be represented in state.

**Verification:**
- [x] Unit tests cover active versus planned module registry entries.
- [x] Manual check: panel renders Music, Clipboard, Notes, and Planned section.

**Dependencies:** Task 1

**Files likely touched:**
- `NotchWorkflowApp/Core/Modules/ModuleRegistry.swift`
- `NotchWorkflowApp/Core/Modules/WorkflowModule.swift`
- `NotchWorkflowApp/UI/ModuleGrid/ModuleGridView.swift`

**Estimated scope:** M

## Task 4: Investigate Apple Music Now-Playing and Lyrics Feasibility
**Description:** Prototype and document the supported way to detect Apple Music playback and lyrics availability.

**Acceptance criteria:**
- [x] Current track detection approach is proven or rejected with evidence.
- [x] Lyrics/synced lyrics official access limitations are documented.
- [x] Minimum macOS version recommendation is updated.
- [x] Liquid Glass/macOS design API availability is checked against the selected SDK where relevant to the music surface.

**Verification:**
- [x] Manual probe against Apple Music.
- [x] Documentation added to `docs/technical-risks.md`.

**Dependencies:** Task 1

**Files likely touched:**
- `NotchWorkflowApp/Modules/Music/AppleMusicProbe.swift`
- `NotchWorkflowApp/Docs/technical-risks.md`
- `outputs/notch-workflow-app-spec.md`

**Estimated scope:** S

## Task 5: Implement Apple Music Provider Boundary and Now-Playing State
**Description:** Add a provider abstraction and first Apple Music implementation for now-playing metadata and playback state.

**Acceptance criteria:**
- [x] `MediaProvider` protocol exists.
- [x] Apple Music provider returns current track metadata when available.
- [x] Music module handles unavailable/inactive state.

**Verification:**
- [x] Unit tests for provider state mapping.
- [x] Manual check with Apple Music playing and paused.

**Dependencies:** Task 4

**Files likely touched:**
- `NotchWorkflowApp/Modules/Music/MediaProvider.swift`
- `NotchWorkflowApp/Modules/Music/AppleMusicProvider.swift`
- `NotchWorkflowApp/Modules/Music/MusicStateStore.swift`

**Estimated scope:** M

## Task 6: Implement Mini Display and Music Detail Panel
**Description:** Connect now-playing state to the persistent mini display and full panel music detail view.

**Acceptance criteria:**
- [x] Mini display shows active track when Apple Music is playing.
- [x] Hover can expand live activity preview.
- [x] Click opens full panel with music detail module.

**Verification:**
- [x] Manual check: play a song, hover, click, and confirm expected UI.
- [x] Snapshot or view tests where feasible.

**Dependencies:** Tasks 2, 3, 5

**Files likely touched:**
- `NotchWorkflowApp/UI/NotchMiniDisplay/MiniDisplayView.swift`
- `NotchWorkflowApp/Modules/Music/MusicPanelView.swift`
- `NotchWorkflowApp/UI/Panel/MainPanelView.swift`

**Estimated scope:** M

## Task 7: Implement Lyrics Fallback States
**Description:** Add the lyrics state model and UI states for synced lyrics, plain lyrics, and no lyrics.

**Acceptance criteria:**
- [x] Lyrics model distinguishes synced, plain, unavailable, and error states.
- [x] UI renders each state cleanly.
- [x] Synced lyrics path is isolated behind a provider/fallback contract.

**Verification:**
- [x] Unit tests for lyrics fallback selection.
- [x] Manual check with mocked synced/plain/unavailable states.

**Dependencies:** Task 6

**Files likely touched:**
- `NotchWorkflowApp/Modules/Lyrics/LyricsProvider.swift`
- `NotchWorkflowApp/Modules/Lyrics/LyricsState.swift`
- `NotchWorkflowApp/Modules/Music/LyricsView.swift`

**Estimated scope:** M

## Task 8: Implement Clipboard Privacy Filters
**Description:** Create filtering rules that reject sensitive-looking text before persistence.

**Acceptance criteria:**
- [x] Password/token/2FA/payment-like patterns are filtered.
- [x] Very large text is rejected.
- [x] Excluded source apps can be represented.

**Verification:**
- [x] Unit tests for sensitive pattern filtering.
- [x] Unit tests for size limits and excluded app handling.

**Dependencies:** Task 1

**Files likely touched:**
- `NotchWorkflowApp/Modules/Clipboard/ClipboardPrivacyFilter.swift`
- `NotchWorkflowApp/Modules/Clipboard/ClipboardPolicy.swift`
- `NotchWorkflowApp/Tests/Unit/ClipboardPrivacyFilterTests.swift`

**Estimated scope:** S

## Task 9: Implement Text-Only Clipboard History Store
**Description:** Monitor and store accepted text clipboard entries locally with default retention of 100 items or 30 days.

**Acceptance criteria:**
- [x] Text clipboard entries are stored locally after filtering.
- [x] Image/file clipboard entries are ignored.
- [x] Retention policy enforces 100-item/30-day defaults.

**Verification:**
- [x] Unit tests for retention and text-only behavior.
- [ ] Manual check: copy text, image, file; only text appears.

**Dependencies:** Task 8

**Files likely touched:**
- `NotchWorkflowApp/Modules/Clipboard/ClipboardMonitor.swift`
- `NotchWorkflowApp/Modules/Clipboard/ClipboardStore.swift`
- `NotchWorkflowApp/Tests/Unit/ClipboardStoreTests.swift`

**Estimated scope:** M

## Task 10: Implement Clipboard Panel UI
**Description:** Add clipboard history UI with search/scan-friendly list and one-click copy.

**Acceptance criteria:**
- [x] Recent text items appear in the Clipboard module.
- [x] User can copy an item back with one click.
- [x] Empty and privacy-filtered states are clear.

**Verification:**
- [ ] Manual check: copy text, open panel, copy history item.
- [x] Unit/build verification for clipboard state, duplicate copy-back guard, and app compilation.

**Dependencies:** Tasks 3, 9

**Files likely touched:**
- `NotchWorkflowApp/Modules/Clipboard/ClipboardPanelView.swift`
- `NotchWorkflowApp/Modules/Clipboard/ClipboardItemRow.swift`
- `NotchWorkflowApp/UI/Panel/MainPanelView.swift`

**Estimated scope:** M

## Task 11: Implement Markdown Scratchpad and Pinned Notes Store
**Description:** Store Markdown scratchpad content and a small set of pinned Markdown notes locally.

**Acceptance criteria:**
- [x] Scratchpad content persists locally.
- [x] User can pin Markdown notes.
- [x] User can unpin/delete pinned notes.

**Verification:**
- [x] Unit tests for pin/unpin/delete persistence.
- [ ] Manual check: write Markdown, relaunch app, confirm persistence.

**Dependencies:** Task 1

**Files likely touched:**
- `NotchWorkflowApp/Modules/Notes/NotesStore.swift`
- `NotchWorkflowApp/Modules/Notes/Note.swift`
- `NotchWorkflowApp/Tests/Unit/NotesStoreTests.swift`

**Estimated scope:** M

## Task 12: Implement Notes Panel UI with Preview and One-Click Copy
**Description:** Add the Markdown notes UI with edit/source mode, readable preview, pinning, and source Markdown copy.

**Acceptance criteria:**
- [x] Scratchpad accepts Markdown.
- [x] Markdown preview is readable.
- [x] One-click copy copies source Markdown by default.

**Verification:**
- [x] Manual check: write Markdown, preview, pin, copy.
- [x] View tests where feasible.

**Dependencies:** Tasks 3, 11

**Files likely touched:**
- `NotchWorkflowApp/Modules/Notes/NotesPanelView.swift`
- `NotchWorkflowApp/Modules/Notes/MarkdownPreviewView.swift`
- `NotchWorkflowApp/Modules/Notes/PinnedNoteRow.swift`

**Estimated scope:** M

## Task 13: Implement Settings Model and Persistence
**Description:** Add local settings persistence for modules, display behavior, interaction behavior, clipboard retention, and notes preferences.

**Acceptance criteria:**
- [ ] Settings persist across app relaunch.
- [ ] Module visibility/order can be saved.
- [ ] Clipboard retention and exclusions can be saved.

**Verification:**
- [ ] Unit tests for settings defaults and persistence.
- [ ] Manual check: change settings, relaunch app, confirm retained.

**Dependencies:** Tasks 3, 9, 11

**Files likely touched:**
- `NotchWorkflowApp/Core/Settings/AppSettings.swift`
- `NotchWorkflowApp/Core/Settings/SettingsStore.swift`
- `NotchWorkflowApp/Tests/Unit/SettingsStoreTests.swift`

**Estimated scope:** M

## Task 14: Implement Interaction and Display Settings UI
**Description:** Add settings for hover affordance, click behavior, live-activity expansion, keyboard shortcut placeholder, selected display, and notch/virtual-island behavior.

**Acceptance criteria:**
- [ ] User can configure hover affordance and live-activity expansion.
- [ ] User can select target display where feasible.
- [ ] Settings affect runtime behavior without restart where practical.

**Verification:**
- [ ] Manual check: change interaction settings and confirm behavior.
- [ ] Manual check: selected display behavior on available setup.

**Dependencies:** Tasks 2, 13

**Files likely touched:**
- `NotchWorkflowApp/UI/Settings/InteractionSettingsView.swift`
- `NotchWorkflowApp/UI/Settings/DisplaySettingsView.swift`
- `NotchWorkflowApp/Core/Settings/AppSettings.swift`

**Estimated scope:** M

## Task 15: Implement Module Settings and Planned Tiles Polish
**Description:** Finish module list settings and the compact planned module presentation in the main panel.

**Acceptance criteria:**
- [ ] Settings shows active and planned modules.
- [ ] Main panel Planned section is compact and clearly disabled.
- [ ] Planned Agents tile communicates read-only future direction without active behavior.

**Verification:**
- [ ] Manual check: planned modules visible in panel and settings.
- [ ] Manual check: disabled tiles do not imply working behavior.

**Dependencies:** Tasks 3, 13

**Files likely touched:**
- `NotchWorkflowApp/UI/Settings/ModuleSettingsView.swift`
- `NotchWorkflowApp/UI/ModuleGrid/PlannedModuleTile.swift`
- `NotchWorkflowApp/UI/Panel/MainPanelView.swift`

**Estimated scope:** S

## Task 16: Add MVP Verification Pass and Docs Update
**Description:** Run full MVP verification, document known limitations, update the spec/plan with any changed decisions, and prepare for implementation review.

**Acceptance criteria:**
- [ ] Build and test commands pass.
- [ ] Manual acceptance checks from the spec pass or have documented blockers.
- [ ] Known limitations and technical risks are documented.

**Verification:**
- [ ] Run project build command.
- [ ] Run project test command.
- [ ] Complete manual MVP checklist.

**Dependencies:** Tasks 1-15

**Files likely touched:**
- `NotchWorkflowApp/Docs/technical-risks.md`
- `outputs/notch-workflow-app-spec.md`
- `tasks/plan.md`
- `tasks/todo.md`

**Estimated scope:** S
