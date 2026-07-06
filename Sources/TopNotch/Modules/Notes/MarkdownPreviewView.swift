import SwiftUI

struct MarkdownPreviewView: View {
    let markdown: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if let attributedString = try? AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)) {
                Text(attributedString)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(markdown)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
