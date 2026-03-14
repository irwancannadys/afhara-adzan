import Foundation

enum AsrMadhab: String, Codable, CaseIterable {
    case shafii = "Syafi'i"
    case hanafi = "Hanafi"

    var shadowFactor: Double {
        switch self {
        case .shafii: 1.0
        case .hanafi: 2.0
        }
    }
}

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

    var localizedName: String {
        switch self {
        case .system: String(localized: "Sistem")
        case .light:  String(localized: "Terang")
        case .dark:   String(localized: "Gelap")
        }
    }
}

enum CalculationMethod: String, Codable, CaseIterable {
    case kemenagRI = "Kemenag RI"
    case mwl       = "Muslim World League"
    case isna      = "ISNA"
    case ummAlQura = "Umm al-Qura"
    case egypt     = "Egyptian"

    var fajrAngle: Double {
        switch self {
        case .kemenagRI: 20.0
        case .mwl:       18.0
        case .isna:      15.0
        case .ummAlQura: 18.5
        case .egypt:     19.5
        }
    }

    // nil = pakai fixed interval (Umm al-Qura)
    var ishaAngle: Double? {
        switch self {
        case .kemenagRI: 18.0
        case .mwl:       17.0
        case .isna:      15.0
        case .ummAlQura: nil
        case .egypt:     17.5
        }
    }

    // Menit setelah Maghrib — hanya untuk Umm al-Qura
    var ishaInterval: Double { 90.0 }

    var localizedName: String {
        switch self {
        case .kemenagRI: String(localized: "Kemenag RI")
        case .mwl:       String(localized: "Muslim World League")
        case .isna:      String(localized: "ISNA")
        case .ummAlQura: String(localized: "Umm al-Qura")
        case .egypt:     String(localized: "Egyptian")
        }
    }
}

struct PrayerSettings: Codable, Equatable {
    var isSoundEnabled       : Bool                    = true
    var isNotificationEnabled: Bool                    = true
    var isCountdownEnabled   : Bool                    = true
    var useAutoLocation      : Bool                    = true
    var notificationOffset   : Int                     = 0
    var appTheme             : AppTheme                = .system
    var launchAtLogin        : Bool                    = false
    var mutedPrayers         : Set<PrayerName>         = []
    var selectedSound        : String                  = "adzan_makkah"
    var calculationMethod    : CalculationMethod       = .kemenagRI
    var showSyuruq           : Bool                    = false
    var asrMadhab            : AsrMadhab               = .shafii
    var showDuaAfterAdzan    : Bool                    = true
    var duaDismissSeconds    : Int                     = 30
    var iqamahEnabled        : Bool                    = true
    var iqamahDurationMinutes: Int                     = 5
    var appLanguage          : AppLanguage             = AppLanguage.systemDefault

    // Custom decoder agar field baru tidak merusak data lama di UserDefaults.
    // Swift synthesized Codable akan throw jika key tidak ada — decodeIfPresent + default value mencegah itu.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        isSoundEnabled        = try c.decodeIfPresent(Bool.self,                  forKey: .isSoundEnabled)        ?? true
        isNotificationEnabled = try c.decodeIfPresent(Bool.self,                  forKey: .isNotificationEnabled) ?? true
        isCountdownEnabled    = try c.decodeIfPresent(Bool.self,                  forKey: .isCountdownEnabled)    ?? true
        useAutoLocation       = try c.decodeIfPresent(Bool.self,                  forKey: .useAutoLocation)       ?? true
        notificationOffset    = try c.decodeIfPresent(Int.self,                   forKey: .notificationOffset)    ?? 0
        appTheme              = try c.decodeIfPresent(AppTheme.self,              forKey: .appTheme)              ?? .system
        launchAtLogin         = try c.decodeIfPresent(Bool.self,                  forKey: .launchAtLogin)         ?? false
        mutedPrayers          = try c.decodeIfPresent(Set<PrayerName>.self,       forKey: .mutedPrayers)          ?? []
        selectedSound         = try c.decodeIfPresent(String.self,                forKey: .selectedSound)         ?? "adzan_makkah"
        calculationMethod     = try c.decodeIfPresent(CalculationMethod.self,     forKey: .calculationMethod)     ?? .kemenagRI
        showSyuruq            = try c.decodeIfPresent(Bool.self,                  forKey: .showSyuruq)            ?? false
        asrMadhab             = try c.decodeIfPresent(AsrMadhab.self,             forKey: .asrMadhab)             ?? .shafii
        showDuaAfterAdzan     = try c.decodeIfPresent(Bool.self,                  forKey: .showDuaAfterAdzan)     ?? true
        duaDismissSeconds     = try c.decodeIfPresent(Int.self,                   forKey: .duaDismissSeconds)     ?? 30
        iqamahEnabled         = try c.decodeIfPresent(Bool.self,                  forKey: .iqamahEnabled)         ?? true
        iqamahDurationMinutes = try c.decodeIfPresent(Int.self,                   forKey: .iqamahDurationMinutes) ?? 5
        appLanguage           = try c.decodeIfPresent(AppLanguage.self,           forKey: .appLanguage)           ?? AppLanguage.systemDefault
    }

    init() {}
}

enum AppLanguage: String, Codable, CaseIterable {
    case id = "id"
    case en = "en"
    case ar = "ar"

    var displayName: String {
        switch self {
        case .id: "Bahasa Indonesia"
        case .en: "English"
        case .ar: "العربية"
        }
    }

    var localeIdentifier: String { rawValue }

    /// Deteksi bahasa system macOS, fallback ke Indonesian jika tidak di-support
    static var systemDefault: AppLanguage {
        guard let preferred = Locale.preferredLanguages.first else { return .id }
        let lang = String(preferred.prefix(2))
        return AppLanguage(rawValue: lang) ?? .id
    }
}
