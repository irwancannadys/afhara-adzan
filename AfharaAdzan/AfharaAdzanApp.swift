import SwiftUI

// MARK: - UI Extensions (SwiftUI/AppKit concerns dipisah dari model layer)

extension AppTheme {
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: nil
        case .light:  NSAppearance(named: .aqua)
        case .dark:   NSAppearance(named: .darkAqua)
        }
    }
}

extension Color {
    /// Accent color dinamis: orange di dark mode, hijau medium di light mode.
    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .light ? Color(red: 0.22, green: 0.52, blue: 0.35) : .orange
    }
}

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
                .onAppear {
                    NSApp.appearance = appState.settings.appTheme.nsAppearance
                }
                .onChange(of: appState.settings.appTheme) { _, theme in
                    NSApp.appearance = theme.nsAppearance
                }
        }
        .defaultSize(width: 700, height: 500)
        .windowResizability(.contentMinSize)
    }
}
