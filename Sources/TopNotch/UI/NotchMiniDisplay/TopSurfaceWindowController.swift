import AppKit
import SwiftUI
import TopNotchCore

/// Window controller that manages the floating top-center panel overlay.
@MainActor
final class TopSurfaceWindowController: NSWindowController {
    private let onTapPill: () -> Void
    
    init(onTapPill: @escaping () -> Void) {
        self.onTapPill = onTapPill
        // Set standard dimensions for the window container
        // Width of 300 and height of 80 gives enough space for hover expansion without clipping.
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 80
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
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
        
        // Retrieve target screen geometry details to initialize TopSurfaceView
        let targetScreen = NSScreen.main ?? NSScreen.screens.first
        let safeAreaTopInset = targetScreen?.safeAreaInsets.top ?? 0
        
        let contentView = TopSurfaceView(safeAreaTopInset: safeAreaTopInset, onTap: onTapPill)
        let hostingView = NSHostingView(rootView: contentView)
        panel.contentView = hostingView
        
        // Position the window on the main screen
        positionWindow()
        
        // Observe display changes (resolution change, external monitor plugged/unplugged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Positions the floating window centered at the top of the selected screen.
    func positionWindow() {
        guard let window = window else { return }
        guard let targetScreen = NSScreen.main ?? NSScreen.screens.first else { return }
        
        let screenMetrics = ScreenMetrics(
            frame: targetScreen.frame,
            safeAreaTopInset: targetScreen.safeAreaInsets.top
        )
        
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        
        let frame = NotchGeometryCalculator.calculateWindowFrame(
            for: screenMetrics,
            windowWidth: windowWidth,
            windowHeight: windowHeight
        )
        
        window.setFrame(frame, display: true)
    }
    
    /// Shows the floating window panel without activating the application.
    func show() {
        window?.orderFrontRegardless()
    }
    
    @objc private func screenParametersChanged() {
        guard let panel = window as? NSPanel else { return }
        guard let targetScreen = NSScreen.main ?? NSScreen.screens.first else { return }
        
        let safeAreaTopInset = targetScreen.safeAreaInsets.top
        
        // Re-inject TopSurfaceView in case the new screen has different safeAreaTopInset (notch vs notchless)
        let contentView = TopSurfaceView(safeAreaTopInset: safeAreaTopInset, onTap: onTapPill)
        panel.contentView = NSHostingView(rootView: contentView)
        
        positionWindow()
    }
}
