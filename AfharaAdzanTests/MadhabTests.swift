import XCTest
@testable import AfharaAdzan

final class MadhabTests: XCTestCase {

    // MARK: - Reference Data
    //
    // Source: aladhan.com API — Kemenag RI method, Jakarta (-6.2088, 106.8456), 13 Mar 2026
    // Syafi'i  Asr = 15:09 WIB
    // Hanafi   Asr = 16:19 WIB
    // Tolerance: ±2 minutes (acceptable for different solar position algorithms)

    private let jakarta = LocationModel(
        latitude: -6.2088,
        longitude: 106.8456,
        cityName: "Jakarta",
        timezone: 7.0
    )

    /// Fixed date: 13 March 2026
    private var testDate: Date {
        var c = DateComponents()
        c.year = 2026; c.month = 3; c.day = 13
        c.hour = 6; c.minute = 0; c.second = 0
        c.timeZone = TimeZone(secondsFromGMT: 7 * 3600)
        return Calendar.current.date(from: c)!
    }

    private let toleranceMinutes: Double = 2.0

    // MARK: - Helper

    /// Extract hour:minute from a Date as total minutes since midnight (local WIB)
    private func minutesSinceMidnight(_ date: Date) -> Int {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 7 * 3600)!
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        return h * 60 + m
    }

    /// Convert "HH:mm" string to minutes since midnight
    private func minutesFromString(_ hhmm: String) -> Int {
        let parts = hhmm.split(separator: ":").map { Int($0)! }
        return parts[0] * 60 + parts[1]
    }

    // MARK: - TC-1: Shadow Factor Values

    func testShadowFactorShafii() {
        XCTAssertEqual(AsrMadhab.shafii.shadowFactor, 1.0,
                       "Syafi'i shadow factor harus 1.0")
    }

    func testShadowFactorHanafi() {
        XCTAssertEqual(AsrMadhab.hanafi.shadowFactor, 2.0,
                       "Hanafi shadow factor harus 2.0")
    }

    // MARK: - TC-2: Default Madhab

    func testDefaultMadhabIsShafii() {
        let settings = PrayerSettings()
        XCTAssertEqual(settings.asrMadhab, .shafii,
                       "Default madhab harus Syafi'i")
    }

    // MARK: - TC-3: Asr Syafi'i Accuracy vs Reference (aladhan.com)

    func testAsrShafiiMatchesReference() {
        let times = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        guard let asr = times.first(where: { $0.name == .asr }) else {
            XCTFail("Asr time not found in calculation result")
            return
        }

        let actual   = minutesSinceMidnight(asr.time)
        let expected = minutesFromString("15:09")  // aladhan.com reference
        let diff     = abs(actual - expected)

        XCTAssertLessThanOrEqual(Double(diff), toleranceMinutes,
            "Asr Syafi'i: got \(actual / 60):\(String(format: "%02d", actual % 60)), " +
            "expected ~15:09 (±\(Int(toleranceMinutes)) min)")
    }

    // MARK: - TC-4: Asr Hanafi Accuracy vs Reference (aladhan.com)

    func testAsrHanafiMatchesReference() {
        let times = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .hanafi
        )
        guard let asr = times.first(where: { $0.name == .asr }) else {
            XCTFail("Asr time not found in calculation result")
            return
        }

        let actual   = minutesSinceMidnight(asr.time)
        let expected = minutesFromString("16:19")  // aladhan.com reference
        let diff     = abs(actual - expected)

        XCTAssertLessThanOrEqual(Double(diff), toleranceMinutes,
            "Asr Hanafi: got \(actual / 60):\(String(format: "%02d", actual % 60)), " +
            "expected ~16:19 (±\(Int(toleranceMinutes)) min)")
    }

    // MARK: - TC-5: Hanafi Asr Always Later Than Syafi'i

    func testHanafiAsrLaterThanShafii() {
        let shafiiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        let hanafiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .hanafi
        )

        let shafiiAsr = shafiiTimes.first(where: { $0.name == .asr })!
        let hanafiAsr = hanafiTimes.first(where: { $0.name == .asr })!

        XCTAssertGreaterThan(hanafiAsr.time, shafiiAsr.time,
            "Asr Hanafi harus lebih lambat dari Syafi'i")
    }

    // MARK: - TC-6: Only Asr Changes Between Madhabs

    func testOnlyAsrChangesWhenMadhabSwitched() {
        let shafiiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        let hanafiTimes = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .hanafi
        )

        let nonAsrNames: [PrayerName] = [.fajr, .sunrise, .dhuhr, .maghrib, .isha]

        for name in nonAsrNames {
            let shafii = shafiiTimes.first(where: { $0.name == name })!
            let hanafi = hanafiTimes.first(where: { $0.name == name })!
            XCTAssertEqual(
                minutesSinceMidnight(shafii.time),
                minutesSinceMidnight(hanafi.time),
                "\(name.rawValue) seharusnya tidak berubah saat ganti madhab"
            )
        }
    }

    // MARK: - TC-7: Persistence — Encode/Decode Madhab

    func testMadhabPersistence() throws {
        var settings = PrayerSettings()
        settings.asrMadhab = .hanafi

        let data    = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: data)

        XCTAssertEqual(decoded.asrMadhab, .hanafi,
                       "Madhab harus tetap Hanafi setelah encode/decode")
    }

    // MARK: - TC-8: Backward Compatibility — Missing Key Defaults to Syafi'i

    func testMissingMadhabKeyDefaultsToShafii() throws {
        // Simulate old settings JSON without asrMadhab key
        let oldJSON = """
        {
            "isSoundEnabled": true,
            "isNotificationEnabled": true,
            "isCountdownEnabled": true,
            "useAutoLocation": true,
            "notificationOffset": 0,
            "appTheme": "Sistem",
            "launchAtLogin": false,
            "mutedPrayers": [],
            "selectedSound": "adzan_makkah",
            "calculationMethod": "Kemenag RI",
            "showSyuruq": false
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: oldJSON)
        XCTAssertEqual(decoded.asrMadhab, .shafii,
                       "Missing asrMadhab key harus fallback ke Syafi'i")
    }

    // MARK: - TC-9: All Prayer Times Returned

    func testCalculatorReturnsAllSixPrayers() {
        let times = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )
        let names = Set(times.map(\.name))
        let expected: Set<PrayerName> = [.fajr, .sunrise, .dhuhr, .asr, .maghrib, .isha]

        XCTAssertEqual(names, expected,
                       "Calculator harus return 6 waktu sholat")
    }

    // MARK: - TC-10: Other Prayer Times Match Reference

    func testOtherPrayerTimesMatchReference() {
        let times = PrayerTimeCalculator.calculate(
            for: testDate, location: jakarta, method: .kemenagRI, asrMadhab: .shafii
        )

        // Reference from aladhan.com (Kemenag RI, Jakarta, 13 Mar 2026)
        let references: [(PrayerName, String)] = [
            (.fajr,    "04:40"),
            (.sunrise, "05:58"),
            (.dhuhr,   "12:02"),
            (.maghrib, "18:07"),
            (.isha,    "19:16"),
        ]

        for (name, refTime) in references {
            let prayer   = times.first(where: { $0.name == name })!
            let actual   = minutesSinceMidnight(prayer.time)
            let expected = minutesFromString(refTime)
            let diff     = abs(actual - expected)

            XCTAssertLessThanOrEqual(Double(diff), toleranceMinutes,
                "\(name.rawValue): got \(actual / 60):\(String(format: "%02d", actual % 60)), " +
                "expected ~\(refTime) (±\(Int(toleranceMinutes)) min)")
        }
    }

    // MARK: - TC-11: Madhab Enum CaseIterable

    func testMadhabHasTwoCases() {
        XCTAssertEqual(AsrMadhab.allCases.count, 2,
                       "Harus ada tepat 2 madhab: Syafi'i dan Hanafi")
    }

    func testMadhabRawValues() {
        XCTAssertEqual(AsrMadhab.shafii.rawValue, "Syafi'i")
        XCTAssertEqual(AsrMadhab.hanafi.rawValue, "Hanafi")
    }
}
