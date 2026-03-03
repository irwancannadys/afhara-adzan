import SwiftUI

struct MenuBarLabel: View {

    @Environment(AppState.self) private var appState

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
    }
}
