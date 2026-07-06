import Foundation

/// Manages local Markdown scratchpad and pinned Markdown notes persistence.
@MainActor
public final class NotesStore: ObservableObject, @unchecked Sendable {

    public static let shared = NotesStore()

    @Published public private(set) var scratchpadMarkdown: String = ""
    @Published public private(set) var pinnedNotes: [Note] = []

    private let customMaxPinnedNotes: Int?
    public let storageURL: URL

    public var maxPinnedNotes: Int {
        customMaxPinnedNotes ?? SettingsStore.shared.settings.notesMaxPinnedCount
    }

    public init(maxPinnedNotes: Int? = nil, storageURL: URL? = nil) {
        self.customMaxPinnedNotes = maxPinnedNotes.map { max(0, $0) }
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        load()
    }

    // MARK: - Scratchpad

    public func updateScratchpad(markdown: String) {
        scratchpadMarkdown = markdown
        save()
    }

    public func clearScratchpad() {
        updateScratchpad(markdown: "")
    }

    // MARK: - Pinned Notes

    @discardableResult
    public func pinNote(markdown: String) -> Note {
        let note = Note(markdown: markdown)
        pinnedNotes.insert(note, at: 0)
        enforcePinnedNotesLimit()
        save()
        return note
    }

    public func updatePinnedNote(id: UUID, markdown: String) {
        guard let index = pinnedNotes.firstIndex(where: { $0.id == id }) else { return }
        pinnedNotes[index].markdown = markdown
        pinnedNotes[index].updatedAt = Date()
        save()
    }

    public func unpinNote(id: UUID) {
        deletePinnedNote(id: id)
    }

    public func deletePinnedNote(id: UUID) {
        pinnedNotes.removeAll { $0.id == id }
        save()
    }

    public func clearPinnedNotes() {
        pinnedNotes.removeAll()
        save()
    }

    public func enforcePinnedNotesLimit() {
        guard pinnedNotes.count > maxPinnedNotes else { return }
        pinnedNotes = Array(pinnedNotes.prefix(maxPinnedNotes))
    }

    // MARK: - Persistence

    public func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(PersistedState(
                scratchpadMarkdown: scratchpadMarkdown,
                pinnedNotes: pinnedNotes
            ))
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            try data.write(to: storageURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist notes: \(error)")
        }
    }

    public func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            scratchpadMarkdown = ""
            pinnedNotes = []
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            let persistedState = try decoder.decode(PersistedState.self, from: data)
            scratchpadMarkdown = persistedState.scratchpadMarkdown
            pinnedNotes = persistedState.pinnedNotes
            let loadedCount = pinnedNotes.count
            enforcePinnedNotesLimit()
            if pinnedNotes.count != loadedCount {
                save()
            }
        } catch {
            assertionFailure("Failed to load notes: \(error)")
            scratchpadMarkdown = ""
            pinnedNotes = []
        }
    }

    // MARK: - Helpers

    private static func defaultStorageURL() -> URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return appSupport
            .appendingPathComponent("TopNotch", isDirectory: true)
            .appendingPathComponent("notes.json")
    }
}

private struct PersistedState: Codable {
    var scratchpadMarkdown: String
    var pinnedNotes: [Note]
}
