import XCTest
@testable import TopNotchCore

final class AppShellConfigurationTests: XCTestCase {
    func testUsesApprovedAppAndProcessNames() {
        let configuration = AppShellConfiguration.taskOneDefault

        XCTAssertEqual(configuration.appName, "Top Notch")
        XCTAssertEqual(configuration.processName, "TopNotch")
    }

    func testLaunchesAsUtilityWithSettingsAvailable() {
        let configuration = AppShellConfiguration.taskOneDefault

        XCTAssertTrue(configuration.launchesWithoutMainWindow)
        XCTAssertTrue(configuration.hasSettingsWindow)
    }
}
