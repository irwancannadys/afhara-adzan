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
    var id             : PrayerName { name }
    let name           : PrayerName
    let time           : Date
    let timezoneOffset : Double
    var isNext: Bool = false
    var isPast: Bool = false

    var timezoneLabel: String {
        switch timezoneOffset {
        case 7:  return "WIB"
        case 8:  return "WITA"
        case 9:  return "WIT"
        default:
            let sign = timezoneOffset >= 0 ? "+" : ""
            let val  = timezoneOffset == timezoneOffset.rounded() ? "\(Int(timezoneOffset))" : "\(timezoneOffset)"
            return "UTC\(sign)\(val)"
        }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    var timeString: String {
        "\(Self.timeFormatter.string(from: time)) \(timezoneLabel)"
    }
}
