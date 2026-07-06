import Foundation

public struct ClipboardEntry: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public let text: String
    public let sourceAppBundleIdentifier: String?
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        text: String,
        sourceAppBundleIdentifier: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.sourceAppBundleIdentifier = sourceAppBundleIdentifier
        self.timestamp = timestamp
    }
}
