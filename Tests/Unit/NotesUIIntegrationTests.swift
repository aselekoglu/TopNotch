import XCTest
import SwiftUI
@testable import TopNotchCore

@MainActor
final class NotesUIIntegrationTests: XCTestCase {
    
    private func tempStorageURL() -> URL {
        let fileName = "notes_ui_test_\(UUID().uuidString).json"
        return URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(fileName)
    }

    private func makeStore(storageURL: URL? = nil) -> NotesStore {
        NotesStore(storageURL: storageURL ?? tempStorageURL())
    }
    
    func testUIStateDefaultsAndOperations() {
        let store = makeStore()
        
        // Simulating the onAppear of the panel
        var viewText = store.scratchpadMarkdown
        XCTAssertEqual(viewText, "")
        
        // Simulating writing text in TextEditor
        viewText = "# Hello World"
        store.updateScratchpad(markdown: viewText)
        XCTAssertEqual(store.scratchpadMarkdown, "# Hello World")
        
        // Simulating Pin Button action
        store.pinNote(markdown: viewText)
        XCTAssertEqual(store.pinnedNotes.count, 1)
        XCTAssertEqual(store.pinnedNotes.first?.markdown, "# Hello World")
        
        // Simulating copy button action
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(store.pinnedNotes.first!.markdown, forType: .string)
        XCTAssertEqual(pasteboard.string(forType: .string), "# Hello World")
        
        // Simulating selecting a pinned note (restores to text and goes to edit/write mode)
        let note = store.pinnedNotes.first!
        viewText = note.markdown
        XCTAssertEqual(viewText, "# Hello World")
        
        // Simulating Delete Button action
        store.deletePinnedNote(id: note.id)
        XCTAssertTrue(store.pinnedNotes.isEmpty)
        
        // Cleanup storage file if exists
        try? FileManager.default.removeItem(at: store.storageURL)
    }
}
