import AppKit
import Combine
import SwiftUI
import TopNotchCore

/// Window controller that manages the floating main panel dropdown dashboard.
@MainActor
final class MainPanelWindowController: NSWindowController {
    nonisolated(unsafe) private var clickMonitor: Any?
    private let onOpenSettings: () -> Void
    private var currentTopSurfaceFrame: CGRect = .zero
    private var cancellables: Set<AnyCancellable> = []
    
    init(onOpenSettings: @escaping () -> Void) {
        self.onOpenSettings = onOpenSettings
        let initialSize = MainPanelMetrics.panelSize(
            for: MusicStateStore.shared.lyricsState,
            screenWidth: (NSScreen.main ?? NSScreen.screens.first)?.visibleFrame.width
        )
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: initialSize.width, height: initialSize.height),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        
        super.init(window: panel)
        
        let contentView = MainPanelView(
            safeAreaTopInset: (NSScreen.main ?? NSScreen.screens.first)?.safeAreaInsets.top ?? 0,
            onOpenSettings: onOpenSettings
        )
        
        panel.contentView = NSHostingView(rootView: contentView)

        MusicStateStore.shared.$lyricsState
            .sink { [weak self] _ in
                self?.resizeVisiblePanel()
            }
            .store(in: &cancellables)

        SettingsStore.shared.$settings
            .sink { [weak self] _ in
                self?.resizeVisiblePanel()
            }
            .store(in: &cancellables)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    deinit {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    /// Toggles the main panel display state.
    func toggle(relativeTo topSurfaceFrame: CGRect, topInset: CGFloat) {
        guard let window = window else { return }
        
        if window.isVisible {
            hide()
        } else {
            show(relativeTo: topSurfaceFrame, topInset: topInset)
        }
    }
    
    /// Positions and displays the main panel below the top surface pill.
    func show(relativeTo topSurfaceFrame: CGRect, topInset: CGFloat) {
        guard let window = window else { return }
        
        self.currentTopSurfaceFrame = topSurfaceFrame
        let targetScreen = screen(containing: topSurfaceFrame)
        installContent(for: targetScreen)
        let panelSize = MainPanelMetrics.panelSize(
            for: MusicStateStore.shared.lyricsState,
            screenWidth: targetScreen?.visibleFrame.width
        )
        
        // Center horizontally below the top surface pill
        let x = topSurfaceFrame.minX + (topSurfaceFrame.width - panelSize.width) / 2
        
        let y = topSurfaceFrame.maxY - panelSize.height
        
        window.setFrame(NSRect(x: x, y: y, width: panelSize.width, height: panelSize.height), display: true)
        window.orderFrontRegardless()
        
        // Start tracking clicks outside the panel to dismiss it
        startClickMonitor()
    }
    
    /// Hides the main panel.
    func hide() {
        window?.orderOut(nil)
        stopClickMonitor()
    }
    
    private func startClickMonitor() {
        stopClickMonitor()
        
        // Global monitor catches clicks outside the app's windows
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let window = self.window, window.isVisible else { return }
            
            let mouseLocation = NSEvent.mouseLocation
            
            // Dismiss if click is outside our panel AND not on the triggering top surface pill
            if !window.frame.contains(mouseLocation) && !self.currentTopSurfaceFrame.contains(mouseLocation) {
                self.hide()
            }
        }
    }
    
    private func stopClickMonitor() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    private func resizeVisiblePanel() {
        guard let window = window, window.isVisible, currentTopSurfaceFrame != .zero else { return }
        show(relativeTo: currentTopSurfaceFrame, topInset: 0)
    }

    private func installContent(for screen: NSScreen?) {
        let safeAreaTopInset = screen?.safeAreaInsets.top ?? 0
        window?.contentView = NSHostingView(
            rootView: MainPanelView(
                safeAreaTopInset: safeAreaTopInset,
                onOpenSettings: onOpenSettings
            )
        )
    }

    private func screen(containing frame: CGRect) -> NSScreen? {
        NSScreen.screens.first { $0.frame.intersects(frame) } ?? NSScreen.main ?? NSScreen.screens.first
    }
}
