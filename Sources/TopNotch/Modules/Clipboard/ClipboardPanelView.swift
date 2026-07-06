import AppKit
import SwiftUI
import TopNotchCore

struct ClipboardPanelView: View {
    @ObservedObject private var store: ClipboardStore
    @State private var searchText = ""
    @State private var recentlyCopiedID: ClipboardEntry.ID?

    init(store: ClipboardStore = .shared) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header

            if store.entries.isEmpty {
                emptyState
            } else {
                if store.lastRejectionReason != nil {
                    privacyFilteredState
                }

                searchField

                if filteredEntries.isEmpty {
                    noSearchResultsState
                } else {
                    entriesList
                }

                privacyNote
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.055))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.86))
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.09))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text("Clipboard")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("\(store.entries.count) recent text item\(store.entries.count == 1 ? "" : "s")")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.38))

            TextField("Search clipboard", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white.opacity(0.92))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.075))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var entriesList: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 7) {
                ForEach(filteredEntries.prefix(3)) { entry in
                    ClipboardItemRow(
                        entry: entry,
                        isRecentlyCopied: recentlyCopiedID == entry.id,
                        onCopy: { copy(entry) }
                    )
                }
            }
            .padding(.vertical, 1)
        }
        .frame(maxHeight: 150)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(store.lastRejectionReason == nil ? "No clipboard history yet" : "Private text was not saved")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.78))

            Text(store.lastRejectionReason == nil ? "Copy regular text and it will appear here. Passwords, tokens, 2FA codes, payment cards, excluded apps, and oversized text are filtered before history." : "The last clipboard change matched the privacy filter, so it was rejected before persistence. Copy regular text to add a history item.")
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.white.opacity(0.52))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.045))
        .cornerRadius(10)
    }

    private var privacyFilteredState: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.62))

            VStack(alignment: .leading, spacing: 2) {
                Text("Private text was not saved")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.78))

                Text("The latest clipboard change matched the privacy filter.")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.white.opacity(0.42))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(Color.white.opacity(0.055))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var noSearchResultsState: some View {
        Text("No saved text matches this search.")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.48))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "lock.shield")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.44))

            Text("Private-looking text is filtered before persistence.")
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.white.opacity(0.44))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var filteredEntries: [ClipboardEntry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.entries }

        return store.entries.filter { entry in
            entry.text.localizedCaseInsensitiveContains(query) ||
            (entry.sourceAppBundleIdentifier?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    private func copy(_ entry: ClipboardEntry) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(entry.text, forType: .string)

        withAnimation(.easeInOut(duration: 0.15)) {
            recentlyCopiedID = entry.id
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if recentlyCopiedID == entry.id {
                withAnimation(.easeInOut(duration: 0.15)) {
                    recentlyCopiedID = nil
                }
            }
        }
    }
}
