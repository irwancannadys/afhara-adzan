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
            center.add(request) { error in
                if let error {
                    NSLog("[AfharaAdzan] Schedule ERROR \(prayer.name.rawValue): \(error.localizedDescription)")
                } else {
                    NSLog("[AfharaAdzan] Scheduled notification for \(prayer.name.localizedName) at \(prayer.timeString)")
                }
            }
        }
    }

    // MARK: - Adzan Notification (langsung, tanpa schedule)

    func sendAdzanNotification(for prayerName: String, timeString: String) {
        NSLog("[AfharaAdzan] sendAdzanNotification called for: \(prayerName)")

        let content      = UNMutableNotificationContent()
        content.title    = String(localized: "Waktu \(prayerName)")
        content.body     = String(localized: "Saatnya \(prayerName) — \(timeString)")
        content.sound    = nil  // Audio ditangani AudioService — tidak double-sound

        let request = UNNotificationRequest(
            identifier: "adzan_\(prayerName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error {
                NSLog("[AfharaAdzan] Adzan notification ERROR: \(error.localizedDescription)")
            } else {
                NSLog("[AfharaAdzan] Adzan notification DELIVERED for \(prayerName)")
                // Auto-remove dari Notification Center setelah 15 detik
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    center.removeDeliveredNotifications(withIdentifiers: [request.identifier])
                }
            }
        }
    }

    // MARK: - Iqamah Notification

    func sendIqamahNotification(for prayerName: String) {
        NSLog("[AfharaAdzan] sendIqamahNotification called for: \(prayerName)")

        let content      = UNMutableNotificationContent()
        content.title    = String(localized: "Iqamah \(prayerName) Selesai")
        content.body     = String(localized: "Saatnya mendirikan sholat")
        content.sound    = .default

        let request = UNNotificationRequest(
            identifier: "iqamah_\(prayerName)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil  // Kirim langsung, tanpa delay
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error {
                NSLog("[AfharaAdzan] Notification ERROR: \(error.localizedDescription)")
            } else {
                NSLog("[AfharaAdzan] Notification DELIVERED for \(prayerName)")
                // Auto-remove dari Notification Center setelah 15 detik
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    center.removeDeliveredNotifications(withIdentifiers: [request.identifier])
                }
            }
        }
    }

    // MARK: - Cancel

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
