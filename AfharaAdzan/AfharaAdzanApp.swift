import SwiftUI

// MARK: - Window Helper

extension NSApplication {
    /// Focus window yang sudah ada, atau buka baru jika belum ada.
    func focusOrOpenMainWindow(openAction: () -> Void) {
        // Main WindowGroup window punya .titled style mask; MenuBarExtra popup & panel tidak
        if let window = windows.first(where: {
            !($0 is NSPanel) && $0.styleMask.contains(.titled)
        }) {
            window.makeKeyAndOrderFront(nil)
            activate(ignoringOtherApps: true)
        } else {
            openAction()
        }
    }
}

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

// MARK: - App Delegate

/// Dipakai untuk menerapkan tema SEBELUM window apapun muncul.
/// NSApp belum ready saat App.init() — AppDelegate.applicationDidFinishLaunching
/// adalah tempat paling awal yang aman untuk mengakses NSApp.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let data     = UserDefaults.standard.data(forKey: "prayer_settings"),
           let settings = try? JSONDecoder().decode(PrayerSettings.self, from: data) {
            NSApp.appearance = settings.appTheme.nsAppearance
        }
    }
}

// MARK: - Main App

@main
struct AfharaAdzanApp: App {

    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
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
                .onChange(of: appState.settings.appTheme) { _, theme in
                    NSApp.appearance = theme.nsAppearance
                }
        }
        .defaultSize(width: 700, height: 500)
        .windowResizability(.contentMinSize)
    }
}
