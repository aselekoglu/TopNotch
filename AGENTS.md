# Top Notch Agent Notes

Before editing this repo, read:

1. `docs/spec.md`
2. `docs/implementation-plan.md`
3. `tasks/todo.md`
4. `docs/current-state.md`

Project rules:

- Keep scope to the approved MVP.
- Do not add cloud sync, accounts, telemetry, analytics, payments, or server-side storage.
- Do not request accessibility, automation, global keyboard hook, or lyrics API access without asking first.
- Clipboard privacy filters must run before persistence, not after.
- Agents are Phase 2 and read-only when implemented later. Do not add agent control actions.
- Prefer boring native macOS implementation with Swift, SwiftUI, and AppKit where needed.
- Verify each task before moving to the next.

Current build/run entrypoint:

```bash
./script/build_and_run.sh --verify
```

Run tests with the Xcode beta toolchain and a scratch path outside the workspace:

```bash
COPYFILE_DISABLE=1 DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer swift test --scratch-path /tmp/topnotch-swiftpm-build
```

Do not use the default workspace `.build` path on this machine: the project lives in a FileProvider-managed location and test bundle codesigning can fail with `resource fork, Finder information, or similar detritus not allowed`.
