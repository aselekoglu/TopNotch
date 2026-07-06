import SwiftUI
import TopNotchCore

/// Renders the layout grid of active modules and compact planned tiles.
struct ModuleGridView: View {
    let activeModules: [WorkflowModule]
    let plannedModules: [WorkflowModule]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !activeModules.isEmpty {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Active")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.52))
                        .textCase(.uppercase)
                        .tracking(1.4)
                    
                    ForEach(activeModules) { module in
                        if module.identifier == .music {
                            MusicWidgetView()
                        } else if module.identifier == .clipboard {
                            ClipboardPanelView()
                        } else if module.identifier == .notes {
                            NotesPanelView()
                        } else {
                            ActiveModuleRow(module: module)
                        }
                    }
                }
            }
            
            if !plannedModules.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Planned")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.46))
                        .textCase(.uppercase)
                        .tracking(1.4)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(plannedModules) { module in
                            PlannedModuleTile(module: module)
                        }
                    }
                }
            }
        }
    }
}

/// A compact row representation of an active module placeholder.
struct ActiveModuleRow: View {
    let module: WorkflowModule
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.iconName)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(module.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle(for: module.identifier))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.055))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private func subtitle(for id: ModuleIdentifier) -> String {
        switch id {
        case .music:
            return "Now playing & lyrics"
        case .clipboard:
            return "Local history store"
        case .notes:
            return "Markdown scratchpad"
        default:
            return "Active module"
        }
    }
}

/// A compact, visually disabled tile representing planned features.
struct PlannedModuleTile: View {
    let module: WorkflowModule
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: module.iconName)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.30))
                .frame(width: 30, height: 30)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
            
            Text(module.name)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.32))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.035))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.055), lineWidth: 1)
        )
    }
}
