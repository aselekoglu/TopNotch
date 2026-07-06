import AppKit
import SwiftUI
import TopNotchCore

/// Window controller that manages the floating main panel dropdown dashboard.
@MainActor
final class MainPanelWindowController: NSWindowController {
    nonisolated(unsafe) private var clickMonitor: Any?
    private var currentTopSurfaceFrame: CGRect = .zero
    
    init(onOpenSettings: @escaping () -> Void) {
        let panelWidth: CGFloat = 320
        let panelHeight: CGFloat = 420
        
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight),
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
        
        // Wrap MainPanelView inside an NSHostingView with premium rounded corners and borders
        let contentView = MainPanelView(onOpenSettings: onOpenSettings)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        
        panel.contentView = NSHostingView(rootView: contentView)
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
        
        let panelWidth = window.frame.width
        let panelHeight = window.frame.height
        
        // Center horizontally below the top surface pill
        let x = topSurfaceFrame.minX + (topSurfaceFrame.width - panelWidth) / 2
        
        // Aligns below the active surface (accounting for notch safe area height or notchless default menu-bar size)
        let pillBottomY = topInset > 0 ? (topSurfaceFrame.maxY - topInset) : (topSurfaceFrame.maxY - 22)
        let y = pillBottomY - panelHeight - 8 // 8pt padding gap
        
        window.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: true)
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
}
