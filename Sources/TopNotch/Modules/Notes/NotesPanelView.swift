import SwiftUI
import TopNotchCore

struct NotesPanelView: View {
    @ObservedObject private var store: NotesStore
    @State private var mode: NotesMode = .write
    @State private var text: String = ""
    @State private var isHoveredPin = false
    @State private var isHoveredClear = false
    @State private var isHoveredCopy = false
    
    init(store: NotesStore = .shared) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            
            if mode == .write {
                TextEditor(text: $text)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(height: 54)
                    .padding(6)
                    .background(Color.white.opacity(0.055))
                    .cornerRadius(8)
                    .onChange(of: text) { oldValue, newValue in
                        store.updateScratchpad(markdown: newValue)
                    }
            } else {
                MarkdownPreviewView(markdown: text)
                    .frame(height: 54)
                    .padding(6)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(8)
            }
            
            controls
            
            if !store.pinnedNotes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(store.pinnedNotes) { note in
                            PinnedNoteRow(
                                note: note,
                                onSelect: {
                                    self.text = note.markdown
                                    self.mode = .write
                                },
                                onDelete: {
                                    store.deletePinnedNote(id: note.id)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            self.text = store.scratchpadMarkdown
        }
    }
    
    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "note.text")
                .font(.system(size: 13))
                .foregroundColor(.white)
            
            Text("Notes")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Picker("Mode", selection: $mode) {
                Text("Write").tag(NotesMode.write)
                Text("Read").tag(NotesMode.read)
            }
            .pickerStyle(.segmented)
            .frame(width: 100)
        }
    }
    
    private var controls: some View {
        HStack(spacing: 8) {
            Button(action: {
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                store.pinNote(markdown: text)
            }) {
                Label("Pin", systemImage: "pin.fill")
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(isHoveredPin ? 0.15 : 0.06))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { h in isHoveredPin = h }
            
            Button(action: {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(text, forType: .string)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(isHoveredCopy ? 0.15 : 0.06))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { h in isHoveredCopy = h }
            
            Spacer()
            
            Button(action: {
                text = ""
                store.clearScratchpad()
            }) {
                Text("Clear")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(isHoveredClear ? 0.15 : 0.06))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .onHover { h in isHoveredClear = h }
        }
    }
}

enum NotesMode {
    case write
    case read
}
