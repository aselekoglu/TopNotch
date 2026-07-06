import SwiftUI
import TopNotchCore

/// The root SwiftUI view for the floating main panel dropdown.
struct MainPanelView: View {
    /// Callback to trigger opening the settings window.
    let onOpenSettings: () -> Void

    @ObservedObject private var musicStore = MusicStateStore.shared
    @State private var selectedTab: PanelTab = .nook

    var body: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    CapsuleLabel(icon: "sparkles", title: "Nook", isSelected: selectedTab == .nook) {
                        selectedTab = .nook
                    }
                    CapsuleLabel(icon: "tray.fill", title: "Tray", isSelected: selectedTab == .tray) {
                        selectedTab = .tray
                    }
                }

                tabContent
            }
            .frame(width: 438, alignment: .leading)

            Divider()
                .frame(height: 110)
                .background(Color.white.opacity(0.10))

            VStack(spacing: 12) {
                NookActionButton(icon: "quote.bubble.fill", title: "Lyrics") {
                    musicStore.showLyrics.toggle()
                }

                NookActionButton(icon: "doc.on.clipboard.fill", title: "Clipboard") {
                    selectedTab = .tray
                }

                HStack(spacing: 10) {
                    ForEach(ModuleRegistry.shared.getPlannedVisibleModules().prefix(3)) { module in
                        Image(systemName: module.iconName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.30))
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.055))
                            .clipShape(Circle())
                            .help(module.name)
                    }
                }
            }
            .frame(width: 170)

            Divider()
                .frame(height: 110)
                .background(Color.white.opacity(0.10))

            VStack(spacing: 10) {
                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.84))
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.075))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Settings")

                VStack(spacing: 8) {
                    Image(systemName: "display")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white.opacity(0.56))

                    Text("Mirror")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.48))
                }
                .frame(width: 88, height: 88)
                .background(Color.white.opacity(0.085))
                .clipShape(Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .frame(width: 780, height: 220)
        .background(
            ZStack {
                Color.black
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.045),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .clipShape(panelShape)
        .overlay(
            panelShape
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .nook:
            HStack(spacing: 14) {
                albumArtwork

                VStack(alignment: .leading, spacing: 5) {
                    Text(musicStore.currentTrack?.title ?? "No track playing")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(musicStore.currentTrack?.album ?? "Apple Music")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.62))
                        .lineLimit(1)

                    Text(musicStore.currentTrack?.artist ?? "Start music to fill the island")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.42))
                        .lineLimit(1)

                    HStack(spacing: 18) {
                        playerButton("backward.fill") {
                            musicStore.previousTrack()
                        }
                        playerButton(musicStore.playbackState == .playing ? "pause.fill" : "play.fill") {
                            musicStore.playpause()
                        }
                        playerButton("forward.fill") {
                            musicStore.nextTrack()
                        }
                    }
                    .padding(.top, 6)
                }
                .frame(width: 218, alignment: .leading)
            }

        case .tray:
            ScrollView(.vertical, showsIndicators: false) {
                ModuleGridView(
                    activeModules: ModuleRegistry.shared.getActiveVisibleModules(),
                    plannedModules: ModuleRegistry.shared.getPlannedVisibleModules()
                )
                .padding(.trailing, 10)
            }
            .frame(height: 138)
        }
    }

    private var albumArtwork: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.48, blue: 0.18),
                            Color(red: 0.33, green: 0.18, blue: 0.13),
                            Color(red: 0.08, green: 0.07, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.white.opacity(0.86))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.13), lineWidth: 1)
                )

            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color(red: 1.0, green: 0.17, blue: 0.32))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
                .offset(x: 4, y: 4)
        }
        .frame(width: 96, height: 96)
    }

    private func playerButton(_ systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white.opacity(0.86))
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
    }

    private var panelShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            cornerRadii: RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: 28,
                bottomTrailing: 28,
                topTrailing: 0
            ),
            style: .continuous
        )
    }
}

private enum PanelTab {
    case nook
    case tray
}

private struct CapsuleLabel: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white.opacity(isSelected ? 0.96 : 0.82))
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(Color.white.opacity(isSelected ? 0.15 : 0.0))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct NookActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.86, blue: 0.18))

                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
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
