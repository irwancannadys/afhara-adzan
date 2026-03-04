import Foundation

enum AppTheme: String, Codable, CaseIterable {
    case system = "Sistem"
    case light  = "Terang"
    case dark   = "Gelap"

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max.fill"
        case .dark:   "moon.fill"
        }
    }
}

struct PrayerSettings: Codable, Equatable {
    var isSoundEnabled       : Bool     = true
    var isNotificationEnabled: Bool     = true
    var isCountdownEnabled   : Bool     = true
    var useAutoLocation      : Bool     = true
    var notificationOffset   : Int      = 0
    var appTheme             : AppTheme = .system
}
