import SwiftUI
import TopNotchCore

struct SettingsView: View {
    let configuration: AppShellConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(configuration.appName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Settings")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                GridRow {
                    Text("Process")
                        .foregroundStyle(.secondary)
                    Text(configuration.processName)
                }
                GridRow {
                    Text("Startup")
                        .foregroundStyle(.secondary)
                    Text(configuration.launchesWithoutMainWindow ? "Menu-bar utility" : "Windowed app")
                }
                GridRow {
                    Text("Preferences")
                        .foregroundStyle(.secondary)
                    Text(configuration.hasSettingsWindow ? "Available" : "Unavailable")
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 440, minHeight: 280)
    }
}
