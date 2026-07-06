import XCTest
@testable import TopNotchCore

final class ClipboardPrivacyFilterTests: XCTestCase {

    func testAcceptsOrdinaryText() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(
            text: "Remember to review the implementation plan before the next pass.",
            sourceAppBundleIdentifier: "com.apple.TextEdit"
        )

        XCTAssertEqual(decision, .accepted)
    }

    func testRejectsPasswordLikeAssignments() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "db_password = hunter2")

        XCTAssertEqual(decision, .rejected(.sensitiveContent(.credential)))
    }

    func testRejectsTokenLikeContent() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "Authorization: Bearer abcdefghijklmnopqrstuvwxyz123456")

        XCTAssertEqual(decision, .rejected(.sensitiveContent(.token)))
    }

    func testRejectsTwoFactorCodesWithContext() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "Your verification code is 493827")

        XCTAssertEqual(decision, .rejected(.sensitiveContent(.twoFactorCode)))
    }

    func testAcceptsShortNumbersWithoutSensitiveContext() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "Office door code changed to 493827")

        XCTAssertEqual(decision, .accepted)
    }

    func testRejectsPaymentCardLikeNumbers() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "Use card 4242 4242 4242 4242 for checkout")

        XCTAssertEqual(decision, .rejected(.sensitiveContent(.paymentCard)))
    }

    func testAcceptsLongNumbersThatFailPaymentCardCheck() {
        let filter = ClipboardPrivacyFilter()

        let decision = filter.evaluate(text: "Reference number 1234 5678 9012 3456")

        XCTAssertEqual(decision, .accepted)
    }

    func testAcceptsTextExactlyAtMaximumLength() {
        let policy = ClipboardPolicy(maximumTextLength: 32)
        let filter = ClipboardPrivacyFilter(policy: policy)

        let decision = filter.evaluate(text: String(repeating: "a", count: 32))

        XCTAssertEqual(decision, .accepted)
    }

    func testRejectsVeryLargeText() {
        let policy = ClipboardPolicy(maximumTextLength: 32)
        let filter = ClipboardPrivacyFilter(policy: policy)

        let decision = filter.evaluate(text: String(repeating: "a", count: 33))

        XCTAssertEqual(decision, .rejected(.exceedsMaximumLength(limit: 32, actual: 33)))
    }

    func testRejectsExcludedSourceApps() {
        let policy = ClipboardPolicy(
            excludedSourceAppBundleIdentifiers: ["com.apple.keychainaccess"]
        )
        let filter = ClipboardPrivacyFilter(policy: policy)

        let decision = filter.evaluate(
            text: "ordinary copied text",
            sourceAppBundleIdentifier: "com.apple.keychainaccess"
        )

        XCTAssertEqual(
            decision,
            .rejected(.excludedSourceApp(bundleIdentifier: "com.apple.keychainaccess"))
        )
    }
}
