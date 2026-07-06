import Foundation

/// Local clipboard capture policy used before any clipboard item is persisted.
public struct ClipboardPolicy: Equatable, Sendable {
    public static let defaultMaximumTextLength = 20_000

    public let maximumTextLength: Int
    public let excludedSourceAppBundleIdentifiers: Set<String>

    public init(
        maximumTextLength: Int = Self.defaultMaximumTextLength,
        excludedSourceAppBundleIdentifiers: Set<String> = []
    ) {
        self.maximumTextLength = maximumTextLength
        self.excludedSourceAppBundleIdentifiers = Set(
            excludedSourceAppBundleIdentifiers.map(Self.normalizeBundleIdentifier)
        )
    }

    public func isSourceExcluded(_ bundleIdentifier: String?) -> Bool {
        guard let bundleIdentifier else {
            return false
        }

        return excludedSourceAppBundleIdentifiers.contains(
            Self.normalizeBundleIdentifier(bundleIdentifier)
        )
    }

    private static func normalizeBundleIdentifier(_ bundleIdentifier: String) -> String {
        bundleIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
