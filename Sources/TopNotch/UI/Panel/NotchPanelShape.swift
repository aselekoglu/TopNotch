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
        let depth = max(0, min(lyricsTabDepth, height * 0.35))
        let sideHeight = height - depth
        let radius = min(cornerRadius, sideHeight / 2)
        
        // X coordinates for the top notch wrap
        let effectiveNotchWidth = hasNotch ? min(notchWidth, width * 0.5) : 0
        let effectiveNotchHeight = hasNotch ? min(notchHeight, sideHeight * 0.45) : 0
        let notchStart = (width - effectiveNotchWidth) / 2
        let notchEnd = notchStart + effectiveNotchWidth
        
        // X coordinates for the bottom lyrics tab
        let effectiveTabWidth = depth > 0 ? min(lyricsTabWidth, max(0, width - (radius * 4))) : 0
        let tabStart = (width - effectiveTabWidth) / 2
        let tabEnd = tabStart + effectiveTabWidth
        
        // 1. Start at top-left corner (flaring into the screen bezel)
        path.move(to: CGPoint(x: 0, y: 0))
        
        if effectiveNotchHeight > 0, effectiveNotchWidth > 0 {
            // 2. Go to the start of the notch area, curving down around it.
            path.addLine(to: CGPoint(x: notchStart - 12, y: 0))

            path.addCurve(
                to: CGPoint(x: notchStart + 8, y: effectiveNotchHeight),
                control1: CGPoint(x: notchStart - 2, y: 0),
                control2: CGPoint(x: notchStart + 2, y: effectiveNotchHeight)
            )

            path.addLine(to: CGPoint(x: notchEnd - 8, y: effectiveNotchHeight))

            path.addCurve(
                to: CGPoint(x: notchEnd + 12, y: 0),
                control1: CGPoint(x: notchEnd - 2, y: effectiveNotchHeight),
                control2: CGPoint(x: notchEnd + 2, y: 0)
            )
        }
        
        // 3. Go to top-right corner
        path.addLine(to: CGPoint(x: width, y: 0))
        
        // 4. Down the right side to the sideHeight boundary
        path.addLine(to: CGPoint(x: width, y: sideHeight - radius))
        
        // Rounded bottom-right corner of the shallow side
        path.addArc(
            center: CGPoint(x: width - radius, y: sideHeight - radius),
            radius: radius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )

        guard depth > 0, effectiveTabWidth > 0 else {
            path.addLine(to: CGPoint(x: radius, y: sideHeight))
            path.addArc(
                center: CGPoint(x: radius, y: sideHeight - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: 0, y: 0))
            return path
        }
        
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
        path.addLine(to: CGPoint(x: radius, y: sideHeight))
        
        // Rounded bottom-left corner of the shallow side
        path.addArc(
            center: CGPoint(x: radius, y: sideHeight - radius),
            radius: radius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // 7. Up the left side to the top-left origin
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        return path
    }
}
