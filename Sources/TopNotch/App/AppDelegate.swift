import AppKit
import TopNotchCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private var settingsWindowController: SettingsWindowController?
    private var topSurfaceWindowController: TopSurfaceWindowController?
    private var mainPanelWindowController: MainPanelWindowController?
    private var clipboardStore: ClipboardStore?
    private var clipboardMonitor: ClipboardMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let clipboardStore = ClipboardStore.shared
        self.clipboardStore = clipboardStore
        let clipboardMonitor = ClipboardMonitor(store: clipboardStore)
        self.clipboardMonitor = clipboardMonitor
        clipboardMonitor.startMonitoring()

        let settingsWindowController = SettingsWindowController()
        self.settingsWindowController = settingsWindowController

        let mainPanelWindowController = MainPanelWindowController(onOpenSettings: { [weak settingsWindowController] in
            settingsWindowController?.show()
        })
        self.mainPanelWindowController = mainPanelWindowController

        let topSurfaceWindowController = TopSurfaceWindowController(onTapPill: { [weak self] in
            guard let self = self else { return }
            if let pillWindow = self.topSurfaceWindowController?.window,
               let targetScreen = NSScreen.main ?? NSScreen.screens.first {
                let topInset = targetScreen.safeAreaInsets.top
                self.mainPanelWindowController?.toggle(relativeTo: pillWindow.frame, topInset: topInset)
            }
        })
        self.topSurfaceWindowController = topSurfaceWindowController
        topSurfaceWindowController.show()

        statusItemController = StatusItemController(
            onOpenSettings: { [weak settingsWindowController] in
                settingsWindowController?.show()
            },
            onQuit: {
                NSApp.terminate(nil)
            }
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor?.stopMonitoring()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
