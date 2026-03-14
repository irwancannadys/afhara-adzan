import Foundation
import UserNotifications

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    func schedule(prayerTimes: [PrayerTime], settings: PrayerSettings) {
        guard settings.isNotificationEnabled else { return }

        let center = UNUserNotificationCenter.current()

        // Hapus hanya prayer notifications, jangan iqamah
        let prayerIds = PrayerName.allCases.map { "prayer_\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: prayerIds)

        for prayer in prayerTimes where prayer.name.isFardhu && !prayer.isPast && !settings.mutedPrayers.contains(prayer.name) {
            let content      = UNMutableNotificationContent()
            content.title    = String(localized: "Waktu \(prayer.name.localizedName)")
            content.body     = String(localized: "Saatnya \(prayer.name.localizedName) — \(prayer.timeString)")
            content.sound    = nil  // Audio ditangani AudioService — tidak double-sound

            var fireDate = prayer.time
            if settings.notificationOffset > 0 {
                fireDate = prayer.time.addingTimeInterval(-Double(settings.notificationOffset) * 60)
            }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.hour, .minute, .second], from: fireDate),
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "prayer_\(prayer.name.rawValue)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    // MARK: - Iqamah Notification

    func sendIqamahNotification(for prayerName: String) {
        let content      = UNMutableNotificationContent()
        content.title    = String(localized: "Waktu Iqamah")
        content.body     = String(localized: "Saatnya iqamah \(prayerName)")
        content.sound    = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "iqamah_\(prayerName)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
