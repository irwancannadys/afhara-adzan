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
    var isSoundEnabled       : Bool            = true
    var isNotificationEnabled: Bool            = true
    var isCountdownEnabled   : Bool            = true
    var useAutoLocation      : Bool            = true
    var notificationOffset   : Int             = 0
    var appTheme             : AppTheme        = .system
    var launchAtLogin        : Bool            = false
    var mutedPrayers         : Set<PrayerName> = []
    var selectedSound        : String          = "adzan_makkah"

    // Custom decoder agar field baru tidak merusak data lama di UserDefaults.
    // Swift synthesized Codable akan throw jika key tidak ada — decodeIfPresent + default value mencegah itu.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        isSoundEnabled        = try c.decodeIfPresent(Bool.self,            forKey: .isSoundEnabled)        ?? true
        isNotificationEnabled = try c.decodeIfPresent(Bool.self,            forKey: .isNotificationEnabled) ?? true
        isCountdownEnabled    = try c.decodeIfPresent(Bool.self,            forKey: .isCountdownEnabled)    ?? true
        useAutoLocation       = try c.decodeIfPresent(Bool.self,            forKey: .useAutoLocation)       ?? true
        notificationOffset    = try c.decodeIfPresent(Int.self,             forKey: .notificationOffset)    ?? 0
        appTheme              = try c.decodeIfPresent(AppTheme.self,        forKey: .appTheme)              ?? .system
        launchAtLogin         = try c.decodeIfPresent(Bool.self,            forKey: .launchAtLogin)         ?? false
        mutedPrayers          = try c.decodeIfPresent(Set<PrayerName>.self, forKey: .mutedPrayers)          ?? []
        selectedSound         = try c.decodeIfPresent(String.self,          forKey: .selectedSound)         ?? "adzan_makkah"
    }

    init() {}
}
