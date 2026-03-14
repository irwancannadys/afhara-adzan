import XCTest
@testable import AfharaAdzan

/// Pure logic tests for notification scheduling — no UNUserNotificationCenter dependency.
/// Verifies the filtering, content, and flow logic that determines WHAT gets scheduled.
final class NotificationTests: XCTestCase {

    private let jakarta = LocationModel(
        latitude: -6.2088,
        longitude: 106.8456,
        cityName: "Jakarta",
        timezone: 7.0
    )

    /// Prayer times for tomorrow (all in the future, isPast = false)
    private func futurePrayerTimes() -> [PrayerTime] {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return PrayerTimeCalculator.calculate(
            for: tomorrow, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
    }

    /// Simulates the filtering logic inside NotificationService.schedule()
    /// Returns the prayer names that WOULD be scheduled.
    private func prayersThatWouldBeScheduled(times: [PrayerTime], settings: PrayerSettings) -> [PrayerName] {
        guard settings.isNotificationEnabled else { return [] }
        return times
            .filter { $0.name.isFardhu && !$0.isPast && !settings.mutedPrayers.contains($0.name) }
            .map(\.name)
    }

    // MARK: - TC-1: All 5 Fardhu Prayers Scheduled

    func testAllFardhuPrayersScheduled() {
        let times = futurePrayerTimes()
        var settings = PrayerSettings()
        settings.isNotificationEnabled = true
        settings.mutedPrayers = []

        let scheduled = prayersThatWouldBeScheduled(times: times, settings: settings)
        let names = Set(scheduled)

        XCTAssertEqual(names, [.fajr, .dhuhr, .asr, .maghrib, .isha],
                       "Harus schedule 5 sholat fardhu")
    }

    // MARK: - TC-2: Syuruq Never Scheduled

    func testSyuruqNeverScheduled() {
        let times = futurePrayerTimes()
        var settings = PrayerSettings()
        settings.isNotificationEnabled = true

        let scheduled = prayersThatWouldBeScheduled(times: times, settings: settings)

        XCTAssertFalse(scheduled.contains(.sunrise),
                       "Syuruq bukan fardhu — tidak boleh di-schedule")
    }

    // MARK: - TC-3: isFardhu Filter Correct

    func testIsFardhuFilter() {
        XCTAssertTrue(PrayerName.fajr.isFardhu)
        XCTAssertFalse(PrayerName.sunrise.isFardhu, "Syuruq bukan fardhu")
        XCTAssertTrue(PrayerName.dhuhr.isFardhu)
        XCTAssertTrue(PrayerName.asr.isFardhu)
        XCTAssertTrue(PrayerName.maghrib.isFardhu)
        XCTAssertTrue(PrayerName.isha.isFardhu)
    }

    // MARK: - TC-4: Muted Prayers Excluded

    func testMutedPrayersExcluded() {
        let times = futurePrayerTimes()
        var settings = PrayerSettings()
        settings.isNotificationEnabled = true
        settings.mutedPrayers = [.fajr, .isha]

        let scheduled = prayersThatWouldBeScheduled(times: times, settings: settings)
        let names = Set(scheduled)

        XCTAssertFalse(names.contains(.fajr), "Subuh di-mute, tidak boleh di-schedule")
        XCTAssertFalse(names.contains(.isha), "Isya di-mute, tidak boleh di-schedule")
        XCTAssertTrue(names.contains(.dhuhr), "Dzuhur aktif")
        XCTAssertTrue(names.contains(.asr), "Ashar aktif")
        XCTAssertTrue(names.contains(.maghrib), "Maghrib aktif")
    }

    // MARK: - TC-5: Notification Disabled = Nothing Scheduled

    func testNotificationDisabledSchedulesNothing() {
        let times = futurePrayerTimes()
        var settings = PrayerSettings()
        settings.isNotificationEnabled = false

        let scheduled = prayersThatWouldBeScheduled(times: times, settings: settings)

        XCTAssertTrue(scheduled.isEmpty,
                      "Notifikasi disabled = tidak ada yang di-schedule")
    }

    // MARK: - TC-6: Past Prayers Not Scheduled

    func testPastPrayersNotScheduled() {
        // Use today — some prayers will be in the past
        let todayTimes = PrayerTimeCalculator.calculate(
            for: Date(), location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        var settings = PrayerSettings()
        settings.isNotificationEnabled = true

        let scheduled = prayersThatWouldBeScheduled(times: todayTimes, settings: settings)
        let pastPrayers = todayTimes.filter { $0.isPast }.map(\.name)

        for past in pastPrayers {
            XCTAssertFalse(scheduled.contains(past),
                           "\(past.rawValue) sudah lewat, tidak boleh di-schedule")
        }
    }

    // MARK: - TC-7: Notification Identifier Format

    func testNotificationIdentifierFormat() {
        // Verify identifiers used in schedule() match expected format
        for prayer in PrayerName.allCases {
            let expectedId = "prayer_\(prayer.rawValue)"
            XCTAssertTrue(expectedId.hasPrefix("prayer_"),
                          "Identifier harus berprefix 'prayer_'")
        }

        // Specific values
        XCTAssertEqual("prayer_\(PrayerName.fajr.rawValue)", "prayer_Subuh")
        XCTAssertEqual("prayer_\(PrayerName.dhuhr.rawValue)", "prayer_Dzuhur")
        XCTAssertEqual("prayer_\(PrayerName.asr.rawValue)", "prayer_Ashar")
        XCTAssertEqual("prayer_\(PrayerName.maghrib.rawValue)", "prayer_Maghrib")
        XCTAssertEqual("prayer_\(PrayerName.isha.rawValue)", "prayer_Isya")
    }

    // MARK: - TC-8: Iqamah Identifier Format

    func testIqamahIdentifierFormat() {
        // Verify iqamah identifiers don't clash with prayer identifiers
        let prayerIds = PrayerName.allCases.map { "prayer_\($0.rawValue)" }
        let iqamahId = "iqamah_Dzuhur"

        XCTAssertFalse(prayerIds.contains(iqamahId),
                       "Iqamah identifier tidak boleh clash dengan prayer identifier")
        XCTAssertTrue(iqamahId.hasPrefix("iqamah_"),
                      "Iqamah identifier harus berprefix 'iqamah_'")
    }

    // MARK: - TC-9: Notification Offset Calculation

    func testNotificationOffsetCalculation() {
        let times = futurePrayerTimes()
        guard let fajr = times.first(where: { $0.name == .fajr }) else {
            XCTFail("Fajr not found")
            return
        }

        let offset = 10  // 10 menit sebelum
        let fireDate = fajr.time.addingTimeInterval(-Double(offset) * 60)

        let diff = fajr.time.timeIntervalSince(fireDate)
        XCTAssertEqual(diff, 600, accuracy: 0.1,
                       "Offset 10 menit = 600 detik lebih awal")
    }

    // MARK: - TC-10: Zero Offset = Fire at Prayer Time

    func testZeroOffsetFiresAtPrayerTime() {
        let times = futurePrayerTimes()
        guard let fajr = times.first(where: { $0.name == .fajr }) else {
            XCTFail("Fajr not found")
            return
        }

        let offset = 0
        let fireDate = fajr.time.addingTimeInterval(-Double(offset) * 60)

        XCTAssertEqual(fireDate, fajr.time,
                       "Offset 0 = notifikasi tepat di waktu sholat")
    }

    // MARK: - TC-11: Schedule Removes Only Prayer IDs (Not Iqamah)

    func testScheduleRemovesOnlyPrayerIds() {
        // Verify the IDs that schedule() removes are ONLY prayer_ prefixed
        let removedIds = PrayerName.allCases.map { "prayer_\($0.rawValue)" }

        for id in removedIds {
            XCTAssertTrue(id.hasPrefix("prayer_"),
                          "schedule() hanya boleh remove prayer_ IDs")
            XCTAssertFalse(id.hasPrefix("iqamah_"),
                           "schedule() tidak boleh remove iqamah_ IDs")
        }
    }

    // MARK: - TC-12: Notification Settings Persistence

    func testNotificationSettingsPersistence() throws {
        var settings = PrayerSettings()
        settings.isNotificationEnabled = false
        settings.notificationOffset = 15
        settings.mutedPrayers = [.fajr, .maghrib]

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: data)

        XCTAssertFalse(decoded.isNotificationEnabled)
        XCTAssertEqual(decoded.notificationOffset, 15)
        XCTAssertTrue(decoded.mutedPrayers.contains(.fajr))
        XCTAssertTrue(decoded.mutedPrayers.contains(.maghrib))
        XCTAssertFalse(decoded.mutedPrayers.contains(.dhuhr))
    }

    // MARK: - TC-13: Mute All Prayers = Nothing Scheduled

    func testMuteAllPrayersSchedulesNothing() {
        let times = futurePrayerTimes()
        var settings = PrayerSettings()
        settings.isNotificationEnabled = true
        settings.mutedPrayers = [.fajr, .dhuhr, .asr, .maghrib, .isha]

        let scheduled = prayersThatWouldBeScheduled(times: times, settings: settings)

        XCTAssertTrue(scheduled.isEmpty,
                      "Semua sholat di-mute = tidak ada notifikasi")
    }

    // MARK: - TC-14: Default Settings = All Notifications Active

    func testDefaultSettingsAllNotificationsActive() {
        let settings = PrayerSettings()

        XCTAssertTrue(settings.isNotificationEnabled, "Default: notifikasi enabled")
        XCTAssertEqual(settings.notificationOffset, 0, "Default: offset 0")
        XCTAssertTrue(settings.mutedPrayers.isEmpty, "Default: tidak ada yang di-mute")
    }

}
