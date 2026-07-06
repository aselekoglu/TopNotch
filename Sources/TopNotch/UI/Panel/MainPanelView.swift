import SwiftUI
import TopNotchCore

/// The root SwiftUI view for the floating main panel dropdown.
struct MainPanelView: View {
    /// Callback to trigger opening the settings window.
    let onOpenSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Panel Header
            HStack {
                Text("Top Notch")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Settings")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.08))
            
            // Scrollable Module Dashboard
            ScrollView(.vertical, showsIndicators: false) {
                ModuleGridView(
                    activeModules: ModuleRegistry.shared.getActiveVisibleModules(),
                    plannedModules: ModuleRegistry.shared.getPlannedVisibleModules()
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .frame(width: 320, height: 420)
        // Background frosted glass visual effect
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
    }
}

/// A SwiftUI wrapper for NSVisualEffectView to enable premium native macOS blur/translucency.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
