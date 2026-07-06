import Foundation
import CoreGraphics

/// Represents the geometry parameters of a display screen, abstracted from NSScreen for unit testing.
public struct ScreenMetrics: Equatable, Sendable {
    public let frame: CGRect
    public let safeAreaTopInset: CGFloat

    public init(frame: CGRect, safeAreaTopInset: CGFloat) {
        self.frame = frame
        self.safeAreaTopInset = safeAreaTopInset
    }
}

/// Geometry utilities for positioning the Top Notch interface.
public struct NotchGeometryCalculator: Sendable {
    /// Calculates the global screen coordinates for the floating window panel.
    /// - Parameters:
    ///   - screen: The screen metrics where the panel should be placed.
    ///   - windowWidth: The width of the floating window frame.
    ///   - windowHeight: The height of the floating window frame.
    /// - Returns: The global CGRect coordinates for the window frame.
    public static func calculateWindowFrame(
        for screen: ScreenMetrics,
        windowWidth: CGFloat,
        windowHeight: CGFloat
    ) -> CGRect {
        // Center horizontally on the target screen
        let x = screen.frame.minX + (screen.frame.width - windowWidth) / 2
        
        // Position flush with the top edge of the screen.
        // In macOS coordinates, y = 0 is at the bottom, so screen.frame.maxY is the top edge.
        let y = screen.frame.maxY - windowHeight
        
        return CGRect(x: x, y: y, width: windowWidth, height: windowHeight)
    }
}
