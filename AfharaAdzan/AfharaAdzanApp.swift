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
    /// Accent utama: #007200 di light, orange di dark.
    static func accent(for scheme: ColorScheme) -> Color {
        scheme == .light ? Color(red: 0, green: 0.447, blue: 0) : .orange
    }
    /// Background highlight row: #F0F7EE di light, orange opacity di dark.
    static func accentBackground(for scheme: ColorScheme) -> Color {
        scheme == .light ? Color(red: 0.941, green: 0.969, blue: 0.933) : .orange.opacity(0.07)
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
