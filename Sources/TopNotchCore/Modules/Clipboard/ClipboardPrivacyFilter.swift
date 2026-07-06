import Foundation

public enum ClipboardSensitiveContentKind: Equatable, Sendable {
    case credential
    case token
    case twoFactorCode
    case paymentCard
}

public enum ClipboardPrivacyRejectionReason: Equatable, Sendable {
    case exceedsMaximumLength(limit: Int, actual: Int)
    case excludedSourceApp(bundleIdentifier: String)
    case sensitiveContent(ClipboardSensitiveContentKind)
}

public enum ClipboardPrivacyDecision: Equatable, Sendable {
    case accepted
    case rejected(ClipboardPrivacyRejectionReason)
}

/// Rejects sensitive-looking clipboard text before any persistence layer can see it.
public struct ClipboardPrivacyFilter: Sendable {
    public let policy: ClipboardPolicy

    public init(policy: ClipboardPolicy = ClipboardPolicy()) {
        self.policy = policy
    }

    public func evaluate(
        text: String,
        sourceAppBundleIdentifier: String? = nil
    ) -> ClipboardPrivacyDecision {
        if text.count > policy.maximumTextLength {
            return .rejected(
                .exceedsMaximumLength(limit: policy.maximumTextLength, actual: text.count)
            )
        }

        if policy.isSourceExcluded(sourceAppBundleIdentifier),
           let sourceAppBundleIdentifier {
            return .rejected(
                .excludedSourceApp(
                    bundleIdentifier: sourceAppBundleIdentifier
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                )
            )
        }

        if Self.matchesCredentialPattern(text) {
            return .rejected(.sensitiveContent(.credential))
        }

        if Self.matchesTokenPattern(text) {
            return .rejected(.sensitiveContent(.token))
        }

        if Self.matchesTwoFactorPattern(text) {
            return .rejected(.sensitiveContent(.twoFactorCode))
        }

        if Self.containsPaymentCardNumber(text) {
            return .rejected(.sensitiveContent(.paymentCard))
        }

        return .accepted
    }

    public func allows(
        text: String,
        sourceAppBundleIdentifier: String? = nil
    ) -> Bool {
        evaluate(
            text: text,
            sourceAppBundleIdentifier: sourceAppBundleIdentifier
        ) == .accepted
    }

    private static func matchesCredentialPattern(_ text: String) -> Bool {
        matches(
            text,
            pattern: #"\b(?:[A-Za-z0-9_-]*(?:password|passcode|pwd|secret)|client[_ -]?secret|private[_ -]?key)\b\s*[:=]\s*['"]?[^'"\s]{4,}"#,
            options: [.caseInsensitive]
        )
    }

    private static func matchesTokenPattern(_ text: String) -> Bool {
        tokenPatterns.contains { pattern in
            matches(text, pattern: pattern, options: [.caseInsensitive])
        }
    }

    private static func matchesTwoFactorPattern(_ text: String) -> Bool {
        matches(
            text,
            pattern: #"\b(?:2fa|mfa|otp|one[-\s]?time(?:\s+password)?|verification|security|login)\b[\s\S]{0,30}\b\d{6,8}\b"#,
            options: [.caseInsensitive]
        )
    }

    private static func containsPaymentCardNumber(_ text: String) -> Bool {
        matches(text, pattern: #"(?:\d[ -]?){13,19}"#) { candidate in
            let digits = candidate.filter(\.isNumber)
            guard (13...19).contains(digits.count), !digits.allSatisfy({ $0 == digits.first }) else {
                return false
            }

            return passesLuhnCheck(digits)
        }
    }

    private static let tokenPatterns = [
        #"\b(?:token|api[_ -]?key|access[_ -]?key|auth(?:orization)?)\b\s*[:=]\s*['"]?[^'"\s]{12,}"#,
        #"\bBearer\s+[A-Za-z0-9._~+/=-]{16,}\b"#,
        #"\bsk-[A-Za-z0-9_-]{20,}\b"#,
        #"\bgh[pousr]_[A-Za-z0-9_]{20,}\b"#,
        #"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"#,
        #"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b"#,
        #"\bxox[baprs]-[A-Za-z0-9-]{10,}\b"#
    ]

    private static func matches(
        _ text: String,
        pattern: String,
        options: NSRegularExpression.Options = []
    ) -> Bool {
        matches(text, pattern: pattern, options: options) { _ in true }
    }

    private static func matches(
        _ text: String,
        pattern: String,
        options: NSRegularExpression.Options = [],
        candidateValidator: (Substring) -> Bool
    ) -> Bool {
        guard let regularExpression = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regularExpression.matches(in: text, range: range).contains { match in
            guard let matchRange = Range(match.range, in: text) else {
                return false
            }

            return candidateValidator(text[matchRange])
        }
    }

    private static func passesLuhnCheck(_ digits: String) -> Bool {
        var sum = 0
        var shouldDouble = false

        for character in digits.reversed() {
            guard var digit = character.wholeNumberValue else {
                return false
            }

            if shouldDouble {
                digit *= 2
                if digit > 9 {
                    digit -= 9
                }
            }

            sum += digit
            shouldDouble.toggle()
        }

        return sum % 10 == 0
    }
}
