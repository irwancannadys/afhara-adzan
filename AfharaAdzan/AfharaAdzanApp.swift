import SwiftUI

@main
struct AfharaAdzanApp: App {

    @State private var appState = AppState()

    var body: some Scene {

        // MARK: - Menu Bar
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            MenuBarLabel()
                .environment(appState)
        }
        .menuBarExtraStyle(.window)

        // MARK: - Desktop Window
        WindowGroup(id: "main") {
            MainWindowView()
                .environment(appState)
        }
        .defaultSize(width: 700, height: 500)
        .windowResizability(.contentMinSize)
    }
}
