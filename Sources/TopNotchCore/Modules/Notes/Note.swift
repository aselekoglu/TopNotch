import Foundation

public struct Note: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public var markdown: String
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        markdown: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.markdown = markdown
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
