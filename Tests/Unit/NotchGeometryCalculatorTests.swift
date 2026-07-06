import XCTest
import CoreGraphics
@testable import TopNotchCore

final class NotchGeometryCalculatorTests: XCTestCase {
    func testCalculateWindowFrameOnPrimaryScreen() {
        // Primary Screen: 1920x1080, bottom-left at (0, 0)
        let screen = ScreenMetrics(
            frame: CGRect(x: 0, y: 0, width: 1920, height: 1080),
            safeAreaTopInset: 0
        )
        
        let windowFrame = NotchGeometryCalculator.calculateWindowFrame(
            for: screen,
            windowWidth: 300,
            windowHeight: 80
        )
        
        // Expected X: screenCenter.x - windowWidth / 2 = 960 - 150 = 810
        // Expected Y: screen.maxY - windowHeight = 1080 - 80 = 1000
        XCTAssertEqual(windowFrame.origin.x, 810)
        XCTAssertEqual(windowFrame.origin.y, 1000)
        XCTAssertEqual(windowFrame.width, 300)
        XCTAssertEqual(windowFrame.height, 80)
    }
    
    func testCalculateWindowFrameOnSecondaryScreenWithOffset() {
        // Secondary Screen to the right: 2560x1440, bottom-left at (1920, 0)
        let screen = ScreenMetrics(
            frame: CGRect(x: 1920, y: 0, width: 2560, height: 1440),
            safeAreaTopInset: 0
        )
        
        let windowFrame = NotchGeometryCalculator.calculateWindowFrame(
            for: screen,
            windowWidth: 300,
            windowHeight: 80
        )
        
        // Expected X: screen.minX + (screenWidth - windowWidth) / 2 = 1920 + (2560 - 300) / 2 = 1920 + 1130 = 3050
        // Expected Y: screen.maxY - windowHeight = 1440 - 80 = 1360
        XCTAssertEqual(windowFrame.origin.x, 3050)
        XCTAssertEqual(windowFrame.origin.y, 1360)
        XCTAssertEqual(windowFrame.width, 300)
        XCTAssertEqual(windowFrame.height, 80)
    }
    
    func testCalculateWindowFrameOnNotchedScreen() {
        // MacBook Pro 14" screen: 1728x1117, top safe area inset of 32pt (notch)
        let screen = ScreenMetrics(
            frame: CGRect(x: 0, y: 0, width: 1728, height: 1117),
            safeAreaTopInset: 32
        )
        
        let windowFrame = NotchGeometryCalculator.calculateWindowFrame(
            for: screen,
            windowWidth: 300,
            windowHeight: 80
        )
        
        // Expected X: screenCenter.x - windowWidth / 2 = 864 - 150 = 714
        // Expected Y: screen.maxY - windowHeight = 1117 - 80 = 1037
        XCTAssertEqual(windowFrame.origin.x, 714)
        XCTAssertEqual(windowFrame.origin.y, 1037)
    }

    func testCalculateTopSurfaceContentLayoutReservesCenteredDeadzone() {
        let layout = NotchGeometryCalculator.calculateTopSurfaceContentLayout(
            surfaceSize: CGSize(width: 360, height: 92),
            deadzoneWidth: 180,
            deadzoneHeight: 28
        )

        XCTAssertEqual(layout.deadzoneFrame.minX, 90, accuracy: 0.001)
        XCTAssertEqual(layout.deadzoneFrame.width, 180, accuracy: 0.001)
        XCTAssertEqual(layout.leadingBandFrame.maxX, layout.deadzoneFrame.minX, accuracy: 0.001)
        XCTAssertEqual(layout.trailingBandFrame.minX, layout.deadzoneFrame.maxX, accuracy: 0.001)
        XCTAssertGreaterThan(layout.lowerBandFrame.minY, layout.deadzoneFrame.maxY)
        XCTAssertEqual(layout.lowerBandFrame.width, 340, accuracy: 0.001)
    }

    func testCalculateTopSurfaceContentLayoutClampsOversizedDeadzone() {
        let layout = NotchGeometryCalculator.calculateTopSurfaceContentLayout(
            surfaceSize: CGSize(width: 140, height: 64),
            deadzoneWidth: 220,
            deadzoneHeight: 30,
            horizontalPadding: 8
        )

        XCTAssertEqual(layout.deadzoneFrame.width, 124, accuracy: 0.001)
        XCTAssertEqual(layout.leadingBandFrame.width, 0, accuracy: 0.001)
        XCTAssertEqual(layout.trailingBandFrame.width, 0, accuracy: 0.001)
        XCTAssertGreaterThan(layout.lowerBandFrame.height, 0)
    }
}
