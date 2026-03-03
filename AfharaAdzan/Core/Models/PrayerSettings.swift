import Foundation

struct PrayerSettings: Codable, Equatable {
    var isSoundEnabled       : Bool = true
    var isNotificationEnabled: Bool = true
    var isCountdownEnabled   : Bool = true
    var useAutoLocation      : Bool = true
    var notificationOffset   : Int  = 0    // menit sebelum waktu sholat
}
