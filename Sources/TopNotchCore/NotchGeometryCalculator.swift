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

public struct TopSurfaceContentLayout: Equatable, Sendable {
    public let deadzoneFrame: CGRect
    public let leadingBandFrame: CGRect
    public let trailingBandFrame: CGRect
    public let lowerBandFrame: CGRect

    public init(
        deadzoneFrame: CGRect,
        leadingBandFrame: CGRect,
        trailingBandFrame: CGRect,
        lowerBandFrame: CGRect
    ) {
        self.deadzoneFrame = deadzoneFrame
        self.leadingBandFrame = leadingBandFrame
        self.trailingBandFrame = trailingBandFrame
        self.lowerBandFrame = lowerBandFrame
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

    /// Calculates content bands that avoid the centered physical notch deadzone.
    public static func calculateTopSurfaceContentLayout(
        surfaceSize: CGSize,
        deadzoneWidth: CGFloat,
        deadzoneHeight: CGFloat,
        horizontalPadding: CGFloat = 10,
        topPadding: CGFloat = 6,
        bottomPadding: CGFloat = 6,
        verticalSpacing: CGFloat = 6
    ) -> TopSurfaceContentLayout {
        let usableWidth = max(0, surfaceSize.width - (horizontalPadding * 2))
        let clampedDeadzoneWidth = min(max(0, deadzoneWidth), usableWidth)
        let clampedDeadzoneHeight = min(max(0, deadzoneHeight), surfaceSize.height)

        let deadzoneX = (surfaceSize.width - clampedDeadzoneWidth) / 2
        let deadzoneFrame = CGRect(
            x: deadzoneX,
            y: topPadding,
            width: clampedDeadzoneWidth,
            height: max(0, clampedDeadzoneHeight - topPadding)
        )

        let leadingBandFrame = CGRect(
            x: horizontalPadding,
            y: topPadding,
            width: max(0, deadzoneFrame.minX - horizontalPadding),
            height: deadzoneFrame.height
        )

        let trailingBandFrame = CGRect(
            x: deadzoneFrame.maxX,
            y: topPadding,
            width: max(0, surfaceSize.width - horizontalPadding - deadzoneFrame.maxX),
            height: deadzoneFrame.height
        )

        let lowerBandY = deadzoneFrame.maxY + verticalSpacing
        let lowerBandFrame = CGRect(
            x: horizontalPadding,
            y: lowerBandY,
            width: usableWidth,
            height: max(0, surfaceSize.height - lowerBandY - bottomPadding)
        )

        return TopSurfaceContentLayout(
            deadzoneFrame: deadzoneFrame,
            leadingBandFrame: leadingBandFrame,
            trailingBandFrame: trailingBandFrame,
            lowerBandFrame: lowerBandFrame
        )
    }
}
