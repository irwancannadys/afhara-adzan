import Foundation

enum PrayerName: String, CaseIterable, Codable, Identifiable {
    case fajr    = "Subuh"
    case sunrise = "Syuruq"
    case dhuhr   = "Dzuhur"
    case asr     = "Ashar"
    case maghrib = "Maghrib"
    case isha    = "Isya"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fajr:    "sun.horizon.fill"
        case .sunrise: "sunrise.fill"
        case .dhuhr:   "sun.max.fill"
        case .asr:     "sun.haze.fill"
        case .maghrib: "sunset.fill"
        case .isha:    "moon.stars.fill"
        }
    }

    var isFardhu: Bool { self != .sunrise }
}

struct PrayerTime: Identifiable, Equatable {
    let id   = UUID()
    let name : PrayerName
    let time : Date
    var isNext: Bool = false
    var isPast: Bool = false

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: time)
    }
}
