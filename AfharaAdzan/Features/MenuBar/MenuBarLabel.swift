import SwiftUI

struct MenuBarLabel: View {

    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "moon.stars.fill")
                .symbolRenderingMode(.hierarchical)

            if appState.settings.isCountdownEnabled,
               !appState.nextPrayerName.isEmpty {
                Text("\(appState.nextPrayerName) \u{2022} \(appState.countdownString)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            NSApp.focusOrOpenMainWindow { openWindow(id: "main") }
        }
    }
}
