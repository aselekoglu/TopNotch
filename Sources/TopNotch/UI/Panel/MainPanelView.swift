import SwiftUI
import TopNotchCore

enum MainPanelMetrics {
    static let preferredWidth: CGFloat = 840
    static let minimumWidth: CGFloat = 560
    static let shallowHeight: CGFloat = 260
    static let lyricsTabDepth: CGFloat = 46
    static let navigationHeight: CGFloat = 46
    static let contentTopInset: CGFloat = 12
    static let lyricsViewHeight: CGFloat = 48
    static let collapsedLyricsHeight: CGFloat = 28

    static func hasLyricsTab(for state: LyricsState) -> Bool {
        switch state {
        case .synced(let lines):
            return !lines.isEmpty
        case .plain(let text):
            return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .loading, .unavailable:
            return false
        }
    }

    static func panelWidth(for screenWidth: CGFloat?) -> CGFloat {
        guard let screenWidth else { return preferredWidth }
        return min(preferredWidth, max(minimumWidth, screenWidth - 24))
    }

    static func panelHeight(for state: LyricsState) -> CGFloat {
        shallowHeight + (hasLyricsTab(for: state) ? lyricsTabDepth : 0)
    }

    static func panelSize(for state: LyricsState, screenWidth: CGFloat?) -> CGSize {
        CGSize(width: panelWidth(for: screenWidth), height: panelHeight(for: state))
    }

    static func lyricsTabWidth(for panelWidth: CGFloat) -> CGFloat {
        min(340, max(260, panelWidth * 0.4))
    }
}

/// The root SwiftUI view for the floating main panel dropdown dashboard.
struct MainPanelView: View {
    let safeAreaTopInset: CGFloat
    let onOpenSettings: () -> Void

    @ObservedObject private var musicStore = MusicStateStore.shared
    @ObservedObject private var settingsStore = SettingsStore.shared

    @State private var selectedSection: PanelSection = .overview

    var body: some View {
        let hasNotch = settingsStore.settings.forceVirtualIslandStyle ? false : (safeAreaTopInset > 0)
        let notchWidth = CGFloat(settingsStore.settings.customNotchWidth)
        let notchHeight = CGFloat(settingsStore.settings.customNotchHeight)
        let hasLyricsTab = MainPanelMetrics.hasLyricsTab(for: musicStore.lyricsState)
        let tabDepth = hasLyricsTab ? MainPanelMetrics.lyricsTabDepth : 0

        GeometryReader { proxy in
            let panelWidth = proxy.size.width
            let panelHeight = proxy.size.height
            let tabWidth = MainPanelMetrics.lyricsTabWidth(for: panelWidth)
            let footerHeight = hasLyricsTab ? MainPanelMetrics.lyricsViewHeight : MainPanelMetrics.collapsedLyricsHeight
            let availableBodyHeight = max(
                158,
                panelHeight - MainPanelMetrics.navigationHeight - MainPanelMetrics.contentTopInset - footerHeight - 18
            )
            let availableColumnsWidth = max(0, panelWidth - 40 - 28)
            let centerWidth = min(292, max(212, availableColumnsWidth * 0.35))
            let sideWidth = max(0, (availableColumnsWidth - centerWidth) / 2)
            let notchClearance = min(max(notchWidth + 28, 132), max(132, panelWidth * 0.32))

            VStack(spacing: 0) {
                navigationBar(notchClearance: notchClearance)
                    .frame(height: MainPanelMetrics.navigationHeight)

                HStack(alignment: .top, spacing: 14) {
                    leftColumn
                        .frame(width: sideWidth, height: availableBodyHeight)

                    NotchMediaPlayerColumn(elapsed: $musicStore.playerPosition)
                        .frame(width: centerWidth, height: availableBodyHeight)

                    rightColumn
                        .frame(width: sideWidth, height: availableBodyHeight)
                }
                .padding(.horizontal, 20)
                .padding(.top, MainPanelMetrics.contentTopInset)

                Spacer(minLength: 0)

                if hasLyricsTab {
                    NotchLyricsView(elapsed: musicStore.playerPosition)
                        .frame(width: tabWidth - 28, height: footerHeight)
                        .padding(.bottom, 2)
                } else {
                    collapsedLyricsFooter
                        .frame(width: min(280, panelWidth * 0.42), height: footerHeight)
                        .padding(.bottom, 6)
                }
            }
            .frame(width: panelWidth, height: panelHeight)
            .background(panelBackground)
            .clipShape(panelShape(
                hasNotch: hasNotch,
                notchWidth: notchWidth,
                notchHeight: notchHeight,
                tabWidth: tabWidth,
                tabDepth: tabDepth
            ))
            .overlay(
                panelShape(
                    hasNotch: hasNotch,
                    notchWidth: notchWidth,
                    notchHeight: notchHeight,
                    tabWidth: tabWidth,
                    tabDepth: tabDepth
                )
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }

    private func navigationBar(notchClearance: CGFloat) -> some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 8) {
                CapsuleLabel(title: "Overview", isSelected: selectedSection == .overview) {
                    selectedSection = .overview
                }
                CapsuleLabel(title: "Media", isSelected: selectedSection == .media) {
                    selectedSection = .media
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 12)

            Color.clear
                .frame(width: notchClearance, height: 1)
                .layoutPriority(2)

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                CapsuleLabel(title: "Agents", isSelected: selectedSection == .agents) {
                    selectedSection = .agents
                }
                CapsuleLabel(title: "Tools", isSelected: selectedSection == .tools) {
                    selectedSection = .tools
                }

                Button(action: onOpenSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .layoutPriority(1)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var leftColumn: some View {
        switch selectedSection {
        case .overview, .agents, .tools:
            NotchCalendarView()
        case .media:
            compactPanel(title: "Media", subtitle: "Now playing is centered for quick scanning.")
        }
    }

    @ViewBuilder
    private var rightColumn: some View {
        switch selectedSection {
        case .overview, .media:
            ClipboardPanelView()
        case .agents:
            compactPanel(title: "Agents", subtitle: "Read-only status is planned for Phase 2.")
        case .tools:
            compactPanel(title: "Tools", subtitle: "Clipboard and local utilities stay on-device.")
        }
    }

    private var collapsedLyricsFooter: some View {
        Text("No lyrics available")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.34))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private var panelBackground: some View {
        ZStack {
            Color.black
            LinearGradient(
                colors: [
                    Color.white.opacity(0.05),
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private func panelShape(
        hasNotch: Bool,
        notchWidth: CGFloat,
        notchHeight: CGFloat,
        tabWidth: CGFloat,
        tabDepth: CGFloat
    ) -> NotchPanelShape {
        NotchPanelShape(
            safeAreaTopInset: safeAreaTopInset,
            hasNotch: hasNotch,
            notchWidth: notchWidth,
            notchHeight: notchHeight,
            lyricsTabWidth: tabWidth,
            lyricsTabDepth: tabDepth
        )
    }

    private func compactPanel(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.48))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.045))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private enum PanelSection {
    case overview
    case media
    case agents
    case tools
}

private struct CapsuleLabel: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(isSelected ? 0.95 : 0.58))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(Color.white.opacity(isSelected ? 0.12 : 0.0))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }
}
