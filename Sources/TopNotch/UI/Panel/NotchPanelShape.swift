import SwiftUI

/// A custom SwiftUI Shape that defines the TopNotch panel geometry.
/// It wraps around the physical camera notch at the top, and extends downward in the center
/// as a U-shaped tab to host the synced lyrics.
struct NotchPanelShape: Shape {
    let safeAreaTopInset: CGFloat
    let hasNotch: Bool
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    
    // Center lyrics tab dimensions
    var lyricsTabWidth: CGFloat = 360
    var lyricsTabDepth: CGFloat = 46
    
    // Corner radii
    var cornerRadius: CGFloat = 20
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let sideHeight = height - lyricsTabDepth
        
        // X coordinates for the top notch wrap
        let notchStart = (width - notchWidth) / 2
        let notchEnd = notchStart + notchWidth
        
        // X coordinates for the bottom lyrics tab
        let tabStart = (width - lyricsTabWidth) / 2
        let tabEnd = tabStart + lyricsTabWidth
        
        // 1. Start at top-left corner (flaring into the screen bezel)
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 2. Go to the start of the notch area, curving down around it
        path.addLine(to: CGPoint(x: notchStart - 12, y: 0))
        
        // Curve down to the bottom of the notch
        path.addCurve(
            to: CGPoint(x: notchStart + 8, y: notchHeight),
            control1: CGPoint(x: notchStart - 2, y: 0),
            control2: CGPoint(x: notchStart + 2, y: notchHeight)
        )
        
        // Bottom of the notch edge
        path.addLine(to: CGPoint(x: notchEnd - 8, y: notchHeight))
        
        // Curve back up to the top bezel edge
        path.addCurve(
            to: CGPoint(x: notchEnd + 12, y: 0),
            control1: CGPoint(x: notchEnd - 2, y: notchHeight),
            control2: CGPoint(x: notchEnd + 2, y: 0)
        )
        
        // 3. Go to top-right corner
        path.addLine(to: CGPoint(x: width, y: 0))
        
        // 4. Down the right side to the sideHeight boundary
        path.addLine(to: CGPoint(x: width, y: sideHeight - cornerRadius))
        
        // Rounded bottom-right corner of the shallow side
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: sideHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        // 5. Bottom edge right segment, leading to the lyrics tab
        path.addLine(to: CGPoint(x: tabEnd + 16, y: sideHeight))
        
        // Curve downward into the U-shaped lyrics tab
        path.addCurve(
            to: CGPoint(x: tabEnd - 12, y: height),
            control1: CGPoint(x: tabEnd + 4, y: sideHeight),
            control2: CGPoint(x: tabEnd - 2, y: height)
        )
        
        // Bottom edge of the lyrics tab
        path.addLine(to: CGPoint(x: tabStart + 12, y: height))
        
        // Curve back up to the shallow left side height
        path.addCurve(
            to: CGPoint(x: tabStart - 16, y: sideHeight),
            control1: CGPoint(x: tabStart + 2, y: height),
            control2: CGPoint(x: tabStart - 4, y: sideHeight)
        )
        
        // 6. Bottom edge left segment
        path.addLine(to: CGPoint(x: cornerRadius, y: sideHeight))
        
        // Rounded bottom-left corner of the shallow side
        path.addArc(
            center: CGPoint(x: cornerRadius, y: sideHeight - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // 7. Up the left side to the top-left origin
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        return path
    }
}
