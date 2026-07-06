import XCTest
@testable import TopNotchCore

@MainActor
final class NotesStoreTests: XCTestCase {

    // MARK: - Helpers

    private func tempStorageURL() -> URL {
        let fileName = "notes_test_\(UUID().uuidString).json"
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
    }

    private func makeStore(maxPinnedNotes: Int = 8, storageURL: URL? = nil) -> NotesStore {
        NotesStore(
            maxPinnedNotes: maxPinnedNotes,
            storageURL: storageURL ?? tempStorageURL()
        )
    }

    // MARK: - Scratchpad

    func testScratchpadMarkdownPersists() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)

        store.updateScratchpad(markdown: "# Today\n\n- Ship Task 11")

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.scratchpadMarkdown, "# Today\n\n- Ship Task 11")
        XCTAssertTrue(reloadedStore.pinnedNotes.isEmpty)

        try? FileManager.default.removeItem(at: url)
    }

    func testClearScratchpadPersistsEmptyMarkdown() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)

        store.updateScratchpad(markdown: "temporary **markdown**")
        store.clearScratchpad()

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.scratchpadMarkdown, "")

        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Pinning

    func testPinNoteStoresMarkdownSource() {
        let store = makeStore()

        let note = store.pinNote(markdown: "## Snippet\n\n`swift test`")

        XCTAssertEqual(store.pinnedNotes.count, 1)
        XCTAssertEqual(store.pinnedNotes.first?.id, note.id)
        XCTAssertEqual(store.pinnedNotes.first?.markdown, "## Snippet\n\n`swift test`")
    }

    func testPinnedNotesArePrepended() {
        let store = makeStore()

        store.pinNote(markdown: "first")
        store.pinNote(markdown: "second")

        XCTAssertEqual(store.pinnedNotes.map(\.markdown), ["second", "first"])
    }

    func testPinnedNotesRespectLimit() {
        let store = makeStore(maxPinnedNotes: 2)

        store.pinNote(markdown: "one")
        store.pinNote(markdown: "two")
        store.pinNote(markdown: "three")

        XCTAssertEqual(store.pinnedNotes.map(\.markdown), ["three", "two"])
    }

    func testNegativePinnedNoteLimitIsClampedToZero() {
        let store = makeStore(maxPinnedNotes: -1)

        store.pinNote(markdown: "not retained")

        XCTAssertEqual(store.maxPinnedNotes, 0)
        XCTAssertTrue(store.pinnedNotes.isEmpty)
    }

    func testUpdatePinnedNoteChangesMarkdownAndPersists() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        let note = store.pinNote(markdown: "old")

        store.updatePinnedNote(id: note.id, markdown: "new **markdown**")

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.pinnedNotes.count, 1)
        XCTAssertEqual(reloadedStore.pinnedNotes.first?.id, note.id)
        XCTAssertEqual(reloadedStore.pinnedNotes.first?.markdown, "new **markdown**")

        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Unpin and delete

    func testUnpinNoteRemovesPinnedNoteAndPersists() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        let keep = store.pinNote(markdown: "keep")
        let remove = store.pinNote(markdown: "remove")

        store.unpinNote(id: remove.id)

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.pinnedNotes.count, 1)
        XCTAssertEqual(reloadedStore.pinnedNotes.first?.id, keep.id)
        XCTAssertEqual(reloadedStore.pinnedNotes.first?.markdown, "keep")

        try? FileManager.default.removeItem(at: url)
    }

    func testDeletePinnedNoteRemovesPinnedNoteAndPersists() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)
        let delete = store.pinNote(markdown: "delete")
        store.pinNote(markdown: "stay")

        store.deletePinnedNote(id: delete.id)

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.pinnedNotes.map(\.markdown), ["stay"])

        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Persistence

    func testPersistenceRoundTripIncludesScratchpadAndPinnedNotes() {
        let url = tempStorageURL()
        let store = makeStore(storageURL: url)

        store.updateScratchpad(markdown: "# Scratchpad")
        let first = store.pinNote(markdown: "- pinned one")
        let second = store.pinNote(markdown: "- pinned two")

        let reloadedStore = makeStore(storageURL: url)

        XCTAssertEqual(reloadedStore.scratchpadMarkdown, "# Scratchpad")
        XCTAssertEqual(reloadedStore.pinnedNotes.map(\.id), [second.id, first.id])
        XCTAssertEqual(reloadedStore.pinnedNotes.map(\.markdown), ["- pinned two", "- pinned one"])

        try? FileManager.default.removeItem(at: url)
    }

    func testLoadFromMissingFileStartsEmpty() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("nonexistent_notes_\(UUID().uuidString).json")
        let store = makeStore(storageURL: url)

        XCTAssertEqual(store.scratchpadMarkdown, "")
        XCTAssertTrue(store.pinnedNotes.isEmpty)
    }
}
