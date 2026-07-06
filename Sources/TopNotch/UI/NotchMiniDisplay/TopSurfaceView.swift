import SwiftUI

/// A SwiftUI view representing the top surface pill (virtual island or physical notch overlay).
struct TopSurfaceView: View {
    /// The top safe area inset of the current display. If > 0, we assume the screen has a physical notch.
    let safeAreaTopInset: CGFloat
    
    /// Callback triggered when the pill is clicked.
    let onTap: () -> Void
    
    /// Tracks whether the mouse cursor is currently hovering over the pill.
    @State private var isHovered = false
    
    /// Returns true if the target display screen has a physical notch.
    var hasNotch: Bool {
        safeAreaTopInset > 0
    }
    
    /// Computes the target width of the pill based on notch presence and hover state.
    var targetWidth: CGFloat {
        if hasNotch {
            // Physical notch dimensions: 200pt base width, expands slightly to 240pt on hover.
            return isHovered ? 240 : 200
        } else {
            // Virtual island: 160pt base width, expands to 200pt on hover.
            return isHovered ? 200 : 160
        }
    }
    
    /// Computes the target height of the pill based on notch presence and hover state.
    var targetHeight: CGFloat {
        if hasNotch {
            // Under compact state, it matches the physical notch height (e.g. 32pt).
            return isHovered ? 48 : safeAreaTopInset
        } else {
            // Under compact state, it is 22pt (sits inside 24pt menu bar), expands to 38pt on hover.
            return isHovered ? 38 : 22
        }
    }
    
    /// Computes the corner radius for the visual appearance.
    var targetCornerRadius: CGFloat {
        if hasNotch {
            // For a physical notch, only the bottom corners are typically rounded by the OS, 
            // but a uniform 12pt corner radius provides a smooth, native look under expansion.
            return 12
        } else {
            // Virtual island uses a fully rounded pill style.
            return targetHeight / 2
        }
    }
    
    /// Top padding offset to align the pill centered in a 24pt menu bar for notchless screens.
    var topPadding: CGFloat {
        if hasNotch {
            return 0
        } else {
            // (24pt standard menu bar - 22pt idle height) / 2 = 1pt to center vertically
            return 1
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: topPadding)
            
            ZStack {
                // Background shape with standard macOS dark color / black to match bezel/notch
                RoundedRectangle(cornerRadius: targetCornerRadius, style: .continuous)
                    .fill(Color.black)
                
                // Content container
                HStack(spacing: 8) {
                    Circle()
                        .fill(isHovered ? Color.green : Color.white.opacity(0.3))
                        .frame(width: 6, height: 6)
                    
                    if isHovered {
                        Text("Top Notch")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(width: targetWidth, height: targetHeight)
            .overlay(
                RoundedRectangle(cornerRadius: targetCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(isHovered ? 0.15 : 0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(isHovered ? 0.4 : 0.15), radius: isHovered ? 8 : 3, y: isHovered ? 4 : 1.5)
            // A fluid spring animation for organic Liquid Glass physical feel
            .animation(.spring(response: 0.28, dampingFraction: 0.75, blendDuration: 0), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
            // Clicking the pill toggles the main panel
            .onTapGesture {
                onTap()
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
