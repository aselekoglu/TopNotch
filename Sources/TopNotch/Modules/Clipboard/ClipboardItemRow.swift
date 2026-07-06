import AppKit
import SwiftUI
import TopNotchCore

struct ClipboardItemRow: View {
    let entry: ClipboardEntry
    let isRecentlyCopied: Bool
    let onCopy: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.text.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .textSelection(.disabled)

                HStack(spacing: 6) {
                    Text(Self.relativeTimestamp.string(for: entry.timestamp) ?? "Recent")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.42))

                    if let source = entry.sourceAppBundleIdentifier, !source.isEmpty {
                        Text(source)
                            .font(.system(size: 10, design: .rounded))
                            .foregroundColor(.white.opacity(0.32))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onCopy) {
                Image(systemName: isRecentlyCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(isRecentlyCopied ? 0.95 : 0.72))
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(isRecentlyCopied ? 0.18 : 0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Copy")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.055))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private static let relativeTimestamp: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}
