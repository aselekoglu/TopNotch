import Foundation

/// Manages text-only clipboard history with privacy filtering before persistence.
///
/// Privacy filters run BEFORE any entry is stored. Entries exceeding retention
/// limits (count or age) are pruned on every mutation.
@MainActor
public final class ClipboardStore: ObservableObject, @unchecked Sendable {

    public static let shared = ClipboardStore()

    @Published public var entries: [ClipboardEntry] = []
    @Published public private(set) var lastRejectionReason: ClipboardPrivacyRejectionReason?

    public let maxItems: Int
    public let maxAgeDays: Int
    public let privacyFilter: ClipboardPrivacyFilter
    public let storageURL: URL

    // MARK: - Init

    public init(
        maxItems: Int = 100,
        maxAgeDays: Int = 30,
        privacyFilter: ClipboardPrivacyFilter = ClipboardPrivacyFilter(),
        storageURL: URL? = nil
    ) {
        self.maxItems = maxItems
        self.maxAgeDays = maxAgeDays
        self.privacyFilter = privacyFilter
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        load()
    }

    // MARK: - Public API

    /// Evaluates text through the privacy filter FIRST.
    /// If accepted and not already present, creates and prepends an entry then enforces retention limits.
    /// If rejected, records the reason without persisting the text.
    public func addEntry(text: String, sourceAppBundleIdentifier: String? = nil) {
        let decision = privacyFilter.evaluate(
            text: text,
            sourceAppBundleIdentifier: sourceAppBundleIdentifier
        )

        guard decision == .accepted else {
            if case let .rejected(reason) = decision {
                lastRejectionReason = reason
            }
            return
        }

        guard !entries.contains(where: { $0.text == text }) else { return }

        lastRejectionReason = nil
        let entry = ClipboardEntry(
            text: text,
            sourceAppBundleIdentifier: sourceAppBundleIdentifier
        )
        entries.insert(entry, at: 0)
        enforceRetention()
        save()
    }

    /// Removes a single entry by UUID.
    public func removeEntry(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    /// Removes all entries.
    public func clearAll() {
        entries.removeAll()
        save()
    }

    /// Trims entries exceeding `maxItems` and removes entries older than `maxAgeDays`.
    public func enforceRetention() {
        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -maxAgeDays,
            to: Date()
        ) ?? Date.distantPast

        entries.removeAll { $0.timestamp < cutoffDate }

        if entries.count > maxItems {
            entries = Array(entries.prefix(maxItems))
        }
    }

    // MARK: - Persistence

    public func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(entries)
            let directory = storageURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            try data.write(to: storageURL, options: .atomic)
        } catch {
            assertionFailure("Failed to persist clipboard history: \(error)")
        }
    }

    public func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            entries = []
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            let loadedEntries = try decoder.decode([ClipboardEntry].self, from: data)
            entries = loadedEntries
            enforceRetention()
            if entries.count != loadedEntries.count {
                save()
            }
        } catch {
            assertionFailure("Failed to load clipboard history: \(error)")
            entries = []
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
            .appendingPathComponent("clipboard_history.json")
    }
}
