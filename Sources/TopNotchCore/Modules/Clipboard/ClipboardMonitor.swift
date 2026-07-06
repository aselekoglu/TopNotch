#if canImport(AppKit)
import AppKit

/// Polls `NSPasteboard.general` for new text-only clipboard content.
///
/// Only `NSPasteboard.PasteboardType.string` items are processed.
/// Images, files, and other pasteboard types are silently ignored.
@MainActor
public final class ClipboardMonitor: @unchecked Sendable {

    private var timer: Timer?
    private var lastChangeCount: Int

    private let store: ClipboardStore
    private let pollInterval: TimeInterval

    // MARK: - Init

    public init(
        store: ClipboardStore = .shared,
        pollInterval: TimeInterval = 1.0
    ) {
        self.store = store
        self.pollInterval = pollInterval
        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    // MARK: - Public API

    /// Starts polling the general pasteboard for new string content.
    public func startMonitoring() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: pollInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }

    /// Stops the polling timer.
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private

    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        // Only process string content. Images, files, and other types are ignored.
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }

        let sourceApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        store.addEntry(text: text, sourceAppBundleIdentifier: sourceApp)
    }
}
#endif
