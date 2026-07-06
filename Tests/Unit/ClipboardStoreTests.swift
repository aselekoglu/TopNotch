import XCTest
@testable import TopNotchCore

@MainActor
final class ClipboardStoreTests: XCTestCase {

    // MARK: - Helpers

    /// Returns a unique temp file URL for each test to avoid cross-test interference.
    private func tempStorageURL() -> URL {
        let fileName = "clipboard_test_\(UUID().uuidString).json"
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
    }

    private func makeStore(
        maxItems: Int = 100,
        maxAgeDays: Int = 30,
        policy: ClipboardPolicy = ClipboardPolicy(),
        storageURL: URL? = nil
    ) -> ClipboardStore {
        ClipboardStore(
            maxItems: maxItems,
            maxAgeDays: maxAgeDays,
            privacyFilter: ClipboardPrivacyFilter(policy: policy),
            storageURL: storageURL ?? tempStorageURL()
        )
    }

    // MARK: - Basic storage

    func testAcceptedTextIsStored() {
        let store = makeStore()

        store.addEntry(text: "Hello, world!", sourceAppBundleIdentifier: "com.apple.TextEdit")

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.text, "Hello, world!")
        XCTAssertEqual(store.entries.first?.sourceAppBundleIdentifier, "com.apple.TextEdit")
    }

    func testMultipleEntriesArePrependedInOrder() {
        let store = makeStore()

        store.addEntry(text: "first")
        store.addEntry(text: "second")
        store.addEntry(text: "third")

        XCTAssertEqual(store.entries.count, 3)
        XCTAssertEqual(store.entries[0].text, "third")
        XCTAssertEqual(store.entries[1].text, "second")
        XCTAssertEqual(store.entries[2].text, "first")
    }

    func testDuplicateTextIsNotStoredAgain() {
        let store = makeStore()

        store.addEntry(text: "repeatable snippet")
        store.addEntry(text: "other snippet")
        store.addEntry(text: "repeatable snippet")

        XCTAssertEqual(store.entries.count, 2)
        XCTAssertEqual(store.entries[0].text, "other snippet")
        XCTAssertEqual(store.entries[1].text, "repeatable snippet")
    }

    // MARK: - Privacy filter rejects sensitive text

    func testSensitiveTextIsRejectedNotStored() {
        let store = makeStore()

        store.addEntry(text: "password = \"secret123\"")

        XCTAssertTrue(store.entries.isEmpty, "Sensitive text should be rejected before storage")
        XCTAssertEqual(store.lastRejectionReason, .sensitiveContent(.credential))
    }

    func testTokenContentIsRejectedNotStored() {
        let store = makeStore()

        store.addEntry(text: "Authorization: Bearer abcdefghijklmnopqrstuvwxyz123456")

        XCTAssertTrue(store.entries.isEmpty, "Token content should be rejected before storage")
    }

    func testExcludedAppContentIsRejected() {
        let policy = ClipboardPolicy(
            excludedSourceAppBundleIdentifiers: ["com.apple.keychainaccess"]
        )
        let store = makeStore(policy: policy)

        store.addEntry(
            text: "harmless text",
            sourceAppBundleIdentifier: "com.apple.keychainaccess"
        )

        XCTAssertTrue(store.entries.isEmpty, "Content from excluded apps should not be stored")
        XCTAssertEqual(
            store.lastRejectionReason,
            .excludedSourceApp(bundleIdentifier: "com.apple.keychainaccess")
        )
    }

    func testAcceptedTextClearsLastRejectionReason() {
        let store = makeStore()

        store.addEntry(text: "password = \"secret123\"")
        XCTAssertNotNil(store.lastRejectionReason)

        store.addEntry(text: "regular project note")

        XCTAssertNil(store.lastRejectionReason)
        XCTAssertEqual(store.entries.first?.text, "regular project note")
    }

    func testDuplicateAcceptedTextDoesNotClearLastRejectionReason() {
        let store = makeStore()

        store.addEntry(text: "existing snippet")
        store.addEntry(text: "password = \"secret123\"")
        store.addEntry(text: "existing snippet")

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertNotNil(store.lastRejectionReason)
    }

    // MARK: - Text-only behavior

    func testOnlyStringTypeAdditionsWork() {
        // The store only has addEntry(text:...) — there is no addEntry for images or files.
        // Verify that calling addEntry with valid text stores it.
        let store = makeStore()

        store.addEntry(text: "plain text copied")

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.text, "plain text copied")
    }

    // MARK: - Retention: maxItems

    func testRetentionTrimsByMaxItems() {
        let store = makeStore(maxItems: 3)

        store.addEntry(text: "one")
        store.addEntry(text: "two")
        store.addEntry(text: "three")
        store.addEntry(text: "four")
        store.addEntry(text: "five")

        XCTAssertEqual(store.entries.count, 3, "Entries exceeding maxItems should be trimmed")
        XCTAssertEqual(store.entries[0].text, "five")
        XCTAssertEqual(store.entries[1].text, "four")
        XCTAssertEqual(store.entries[2].text, "three")
    }

    // MARK: - Retention: maxAgeDays

    func testRetentionPurgesOldEntries() {
        let store = makeStore(maxAgeDays: 7)

        // Manually inject entries with old timestamps.
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let recentDate = Date()

        let oldEntry = ClipboardEntry(
            text: "old entry",
            timestamp: oldDate
        )
        let recentEntry = ClipboardEntry(
            text: "recent entry",
            timestamp: recentDate
        )

        store.entries = [recentEntry, oldEntry]
        store.enforceRetention()

        XCTAssertEqual(store.entries.count, 1, "Entries older than maxAgeDays should be purged")
        XCTAssertEqual(store.entries.first?.text, "recent entry")
    }

    func testRetentionKeepsEntriesWithinAgeCutoff() {
        let store = makeStore(maxAgeDays: 30)

        let withinRange = Calendar.current.date(byAdding: .day, value: -15, to: Date())!
        let entry = ClipboardEntry(text: "within range", timestamp: withinRange)

        store.entries = [entry]
        store.enforceRetention()

        XCTAssertEqual(store.entries.count, 1)
    }

    // MARK: - removeEntry and clearAll

    func testRemoveEntryById() {
        let store = makeStore()

        store.addEntry(text: "keep this")
        store.addEntry(text: "remove this")

        let idToRemove = store.entries.first!.id
        store.removeEntry(id: idToRemove)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.text, "keep this")
    }

    func testClearAllRemovesEverything() {
        let store = makeStore()

        store.addEntry(text: "one")
        store.addEntry(text: "two")
        store.addEntry(text: "three")

        store.clearAll()

        XCTAssertTrue(store.entries.isEmpty)
    }

    // MARK: - Persistence

    func testPersistenceRoundTrip() {
        let url = tempStorageURL()
        let store1 = makeStore(storageURL: url)

        store1.addEntry(text: "persisted entry", sourceAppBundleIdentifier: "com.example.app")

        // Create a second store pointing at the same file; load() runs in init.
        let store2 = makeStore(storageURL: url)

        XCTAssertEqual(store2.entries.count, 1)
        XCTAssertEqual(store2.entries.first?.text, "persisted entry")
        XCTAssertEqual(store2.entries.first?.sourceAppBundleIdentifier, "com.example.app")

        // Clean up.
        try? FileManager.default.removeItem(at: url)
    }

    func testLoadFromMissingFileStartsEmpty() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("nonexistent_\(UUID().uuidString).json")
        let store = makeStore(storageURL: url)

        XCTAssertTrue(store.entries.isEmpty)
    }

    func testLoadEnforcesRetention() throws {
        let url = tempStorageURL()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let expiredTimestamp = Calendar.current.date(byAdding: .day, value: -40, to: Date())!
        let freshTimestamp = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let fixtures = [
            ClipboardEntry(text: "fresh", timestamp: freshTimestamp),
            ClipboardEntry(text: "expired", timestamp: expiredTimestamp)
        ]
        let data = try encoder.encode(fixtures)
        try data.write(to: url, options: .atomic)

        let store = makeStore(maxAgeDays: 30, storageURL: url)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries.first?.text, "fresh")

        try? FileManager.default.removeItem(at: url)
    }

    func testClearAllDeletesPersistence() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)

        store.addEntry(text: "will be cleared")
        store.clearAll()

        // Reload from same file — should be empty (file contains []).
        let store2 = makeStore(storageURL: url)
        XCTAssertTrue(store2.entries.isEmpty)

        try? FileManager.default.removeItem(at: url)
    }
}
