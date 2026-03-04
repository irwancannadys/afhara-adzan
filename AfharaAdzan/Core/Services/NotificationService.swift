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
        center.removeAllPendingNotificationRequests()

        for prayer in prayerTimes where prayer.name.isFardhu && !prayer.isPast && !settings.mutedPrayers.contains(prayer.name) {
            let content      = UNMutableNotificationContent()
            content.title    = "Waktu \(prayer.name.rawValue)"
            content.body     = "Saatnya \(prayer.name.rawValue) \u{2014} \(prayer.timeString)"
            content.sound    = settings.isSoundEnabled ? .default : nil

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

    // MARK: - Cancel

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
