import AppKit
import Combine
import SwiftUI
import TopNotchCore

/// Window controller that manages the floating top-center panel overlay.
@MainActor
final class TopSurfaceWindowController: NSWindowController {
    private let onTapPill: () -> Void
    private var activeScreen: NSScreen?
    nonisolated(unsafe) private var screenTrackingTimer: Timer?
    private var cancellables: Set<AnyCancellable> = []
    
    static let windowHorizontalPadding: CGFloat = 30
    static let windowTopPadding: CGFloat = 20
    static let windowBottomPadding: CGFloat = 30

    init(onTapPill: @escaping () -> Void) {
        self.onTapPill = onTapPill
        let initialWindowSize = Self.windowSize(for: SettingsStore.shared.settings)
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: initialWindowSize.width, height: initialWindowSize.height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        
        super.init(window: panel)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        SettingsStore.shared.$settings
            .sink { [weak self] _ in
                self?.refreshForCurrentEnvironment(forceRehost: false)
            }
            .store(in: &cancellables)

        refreshForCurrentEnvironment(forceRehost: true)
        startScreenTracking()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    deinit {
        screenTrackingTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Positions the floating window centered at the top of the selected screen.
    func positionWindow() {
        guard let window = window else { return }
        guard let targetScreen = activeScreen ?? Self.screenContainingMouse() ?? NSScreen.main ?? NSScreen.screens.first else { return }
        
        let screenMetrics = ScreenMetrics(
            frame: targetScreen.frame,
            safeAreaTopInset: targetScreen.safeAreaInsets.top
        )
        
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        
        var frame = NotchGeometryCalculator.calculateWindowFrame(
            for: screenMetrics,
            windowWidth: windowWidth,
            windowHeight: windowHeight
        )
        
        // Offset window y-position to align the padded view with the top edge of screen
        frame.origin.y += Self.windowTopPadding
        
        window.setFrame(frame, display: true)
    }
    
    /// Shows the floating window panel without activating the application.
    func show() {
        window?.orderFrontRegardless()
    }
    
    @objc private func screenParametersChanged() {
        refreshForCurrentEnvironment(forceRehost: true)
    }

    private func startScreenTracking() {
        screenTrackingTimer?.invalidate()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshForCurrentEnvironment(forceRehost: false)
            }
        }
        screenTrackingTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func refreshForCurrentEnvironment(forceRehost: Bool) {
        guard let panel = window as? NSPanel else { return }

        let resolvedScreen = Self.screenContainingMouse() ?? activeScreen ?? NSScreen.main ?? NSScreen.screens.first
        let screenChanged = resolvedScreen.map(screenIdentifier) != activeScreen.map(screenIdentifier)
        if let resolvedScreen {
            activeScreen = resolvedScreen
            SettingsStore.shared.setActiveScreen(resolvedScreen)
        }

        let updatedSize = Self.windowSize(for: SettingsStore.shared.settings)
        if panel.frame.size != updatedSize {
            panel.setContentSize(updatedSize)
        }

        if forceRehost || screenChanged || panel.contentView == nil {
            let safeAreaTopInset = activeScreen?.safeAreaInsets.top ?? 0
            let contentView = TopSurfaceView(
                safeAreaTopInset: safeAreaTopInset,
                onTap: onTapPill,
                windowHorizontalPadding: Self.windowHorizontalPadding,
                windowTopPadding: Self.windowTopPadding,
                windowBottomPadding: Self.windowBottomPadding
            )
            let hostingView = NSHostingView(rootView: contentView)
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor
            panel.contentView = hostingView
        }

        positionWindow()
    }

    private func screenIdentifier(_ screen: NSScreen) -> ObjectIdentifier {
        ObjectIdentifier(screen)
    }

    private static func screenContainingMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) }
    }

    private static func windowSize(for settings: AppSettings) -> CGSize {
        CGSize(
            width: CGFloat(max(settings.inactiveSurfaceWidth, settings.hoverSurfaceWidth)) + 2 * windowHorizontalPadding,
            height: CGFloat(max(settings.inactiveSurfaceHeight, settings.hoverSurfaceHeight)) + windowTopPadding + windowBottomPadding
        )
    }
}
