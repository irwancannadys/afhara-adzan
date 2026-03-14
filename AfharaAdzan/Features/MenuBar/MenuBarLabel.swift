import SwiftUI

struct MenuBarLabel: View {

    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "moon.stars.fill")
                .symbolRenderingMode(.hierarchical)

            if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                let minutes = remaining / 60
                let seconds = remaining % 60
                Text(String(localized: "Iqamah \(prayerName) \u{2022} \(String(format: "%02d:%02d", minutes, seconds))"))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            } else if appState.settings.isCountdownEnabled,
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
