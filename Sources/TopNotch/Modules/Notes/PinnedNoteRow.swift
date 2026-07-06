import SwiftUI
import TopNotchCore

struct PinnedNoteRow: View {
    let note: Note
    let onSelect: () -> Void
    let onDelete: () -> Void
    @State private var isHovered = false
    @State private var recentlyCopied = false
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(note.markdown.components(separatedBy: "\n").first ?? "Empty Note")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(note.markdown)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
            }
            .frame(width: 80, alignment: .leading)
            .onTapGesture(perform: onSelect)
            
            HStack(spacing: 4) {
                Button(action: copyToClipboard) {
                    Image(systemName: recentlyCopied ? "checkmark" : "doc.on.doc.fill")
                        .font(.system(size: 8))
                        .foregroundColor(recentlyCopied ? .green : .white.opacity(0.6))
                        .frame(width: 18, height: 18)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.red.opacity(0.8))
                        .frame(width: 18, height: 18)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(isHovered ? 0.085 : 0.045))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .onHover { h in isHovered = h }
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(note.markdown, forType: .string)
        
        withAnimation(.easeInOut(duration: 0.15)) {
            recentlyCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.15)) {
                recentlyCopied = false
            }
        }
    }
}
