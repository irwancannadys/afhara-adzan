import XCTest
@testable import AfharaAdzan

final class IqamahTests: XCTestCase {

    // MARK: - TC-1: IqamahState.idle Is Not Active

    func testIdleStateIsNotActive() {
        let state = IqamahState.idle
        XCTAssertFalse(state.isActive,
                       "IqamahState.idle harus isActive = false")
    }

    // MARK: - TC-2: IqamahState.countdown Is Active

    func testCountdownStateIsActive() {
        let state = IqamahState.countdown(prayerName: "Dzuhur", remaining: 300)
        XCTAssertTrue(state.isActive,
                      "IqamahState.countdown harus isActive = true")
    }

    // MARK: - TC-3: IqamahState Equatable

    func testIqamahStateEquatable() {
        let a = IqamahState.countdown(prayerName: "Dzuhur", remaining: 300)
        let b = IqamahState.countdown(prayerName: "Dzuhur", remaining: 300)
        let c = IqamahState.countdown(prayerName: "Ashar", remaining: 300)
        let d = IqamahState.countdown(prayerName: "Dzuhur", remaining: 200)

        XCTAssertEqual(a, b, "Same prayer + remaining harus equal")
        XCTAssertNotEqual(a, c, "Beda prayer harus not equal")
        XCTAssertNotEqual(a, d, "Beda remaining harus not equal")
        XCTAssertNotEqual(IqamahState.idle, a, "idle vs countdown harus not equal")
    }

    // MARK: - TC-4: Default Settings — Iqamah Enabled

    func testDefaultIqamahEnabled() {
        let settings = PrayerSettings()
        XCTAssertTrue(settings.iqamahEnabled,
                      "Default iqamahEnabled harus true")
    }

    // MARK: - TC-5: Default Iqamah Duration = 10 Minutes

    func testDefaultIqamahDuration() {
        let settings = PrayerSettings()
        XCTAssertEqual(settings.iqamahDurationMinutes, 10,
                       "Default iqamah duration harus 10 menit")
    }

    // MARK: - TC-6: Iqamah Duration Range (1-30)

    func testIqamahDurationRange() {
        var settings = PrayerSettings()

        settings.iqamahDurationMinutes = 1
        XCTAssertEqual(settings.iqamahDurationMinutes, 1, "Minimum 1 menit harus bisa di-set")

        settings.iqamahDurationMinutes = 30
        XCTAssertEqual(settings.iqamahDurationMinutes, 30, "Maximum 30 menit harus bisa di-set")
    }

    // MARK: - TC-7: Iqamah Settings Persistence

    func testIqamahSettingsPersistence() throws {
        var settings = PrayerSettings()
        settings.iqamahEnabled = false
        settings.iqamahDurationMinutes = 15

        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: data)

        XCTAssertEqual(decoded.iqamahEnabled, false,
                       "iqamahEnabled harus persist setelah encode/decode")
        XCTAssertEqual(decoded.iqamahDurationMinutes, 15,
                       "iqamahDurationMinutes harus persist setelah encode/decode")
    }

    // MARK: - TC-8: Backward Compatibility — Missing Iqamah Keys

    func testMissingIqamahKeysDefaultCorrectly() throws {
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
            "showSyuruq": false,
            "asrMadhab": "Syafi'i"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(PrayerSettings.self, from: oldJSON)

        XCTAssertTrue(decoded.iqamahEnabled,
                      "Missing iqamahEnabled harus default true")
        XCTAssertEqual(decoded.iqamahDurationMinutes, 10,
                       "Missing iqamahDurationMinutes harus default 10")
    }

    // MARK: - TC-9: AppState Iqamah Starts After Adzan Finishes

    @MainActor
    func testIqamahStartsAfterAdzanFinished() async throws {
        let appState = AppState()

        // Verify initial state is idle
        XCTAssertEqual(appState.iqamahState, .idle,
                       "Initial iqamah state harus idle")

        // Ensure iqamah is enabled
        appState.settings.iqamahEnabled = true
        appState.settings.iqamahDurationMinutes = 5

        // Simulate adzan finished by calling handleAdzanFinished
        // We need to trigger this via AudioService callback
        AudioService.shared.onAdzanFinished?()

        // Wait a brief moment for the state to update
        try await Task.sleep(for: .milliseconds(200))

        // After adzan finishes, iqamah should be counting down
        XCTAssertTrue(appState.iqamahState.isActive,
                      "Iqamah harus active setelah adzan selesai")

        if case .countdown(_, let remaining) = appState.iqamahState {
            // 5 minutes = 300 seconds, should be close to 300
            XCTAssertGreaterThan(remaining, 290,
                                 "Remaining harus mendekati 5 menit (300 detik)")
            XCTAssertLessThanOrEqual(remaining, 300,
                                     "Remaining tidak boleh melebihi durasi")
        }

        // Cleanup
        appState.stopAll()
    }

    // MARK: - TC-10: Iqamah Disabled = No Countdown After Adzan

    @MainActor
    func testIqamahDisabledNoCountdown() async throws {
        let appState = AppState()
        appState.settings.iqamahEnabled = false

        // Simulate adzan finished
        AudioService.shared.onAdzanFinished?()
        try await Task.sleep(for: .milliseconds(200))

        XCTAssertEqual(appState.iqamahState, .idle,
                       "Iqamah disabled = state harus tetap idle setelah adzan")

        appState.stopAll()
    }

    // MARK: - TC-11: StopAll Resets Iqamah State

    @MainActor
    func testStopAllResetsIqamah() async throws {
        let appState = AppState()
        appState.settings.iqamahEnabled = true
        appState.settings.iqamahDurationMinutes = 10

        // Start iqamah via adzan finished
        AudioService.shared.onAdzanFinished?()
        try await Task.sleep(for: .milliseconds(200))

        // Verify iqamah is active
        XCTAssertTrue(appState.iqamahState.isActive,
                      "Iqamah harus active sebelum stopAll")

        // Stop all
        appState.stopAll()

        XCTAssertEqual(appState.iqamahState, .idle,
                       "StopAll harus reset iqamah ke idle")
    }

    // MARK: - TC-12: Dua Banner Shows After Adzan

    @MainActor
    func testDuaBannerShowsAfterAdzan() async throws {
        let appState = AppState()
        appState.settings.showDuaAfterAdzan = true

        AudioService.shared.onAdzanFinished?()
        try await Task.sleep(for: .milliseconds(200))

        XCTAssertTrue(appState.showDoaBanner,
                      "Doa banner harus muncul setelah adzan selesai")

        appState.stopAll()
    }

    // MARK: - TC-13: Dua Banner Disabled = No Banner

    @MainActor
    func testDuaBannerDisabled() async throws {
        let appState = AppState()
        appState.settings.showDuaAfterAdzan = false

        AudioService.shared.onAdzanFinished?()
        try await Task.sleep(for: .milliseconds(200))

        XCTAssertFalse(appState.showDoaBanner,
                       "Doa banner harus tidak muncul kalau disabled")

        appState.stopAll()
    }

    // MARK: - TC-14: Dismiss Doa Banner Manually

    @MainActor
    func testDismissDoaBannerManually() async throws {
        let appState = AppState()
        appState.settings.showDuaAfterAdzan = true
        appState.settings.duaDismissSeconds = 0  // Tidak auto-dismiss

        AudioService.shared.onAdzanFinished?()
        try await Task.sleep(for: .milliseconds(200))

        XCTAssertTrue(appState.showDoaBanner, "Banner harus muncul")

        appState.dismissDoaBanner()

        XCTAssertFalse(appState.showDoaBanner,
                       "Banner harus hilang setelah dismiss manual")

        appState.stopAll()
    }

    // MARK: - TC-15: Iqamah Countdown Value Correct

    func testIqamahCountdownValue() {
        let state = IqamahState.countdown(prayerName: "Maghrib", remaining: 600)

        if case .countdown(let name, let remaining) = state {
            XCTAssertEqual(name, "Maghrib")
            XCTAssertEqual(remaining, 600, "10 menit = 600 detik")
        } else {
            XCTFail("State harus countdown")
        }
    }

    // MARK: - TC-16: Multiple Iqamah Durations Settings

    func testIqamahDurationSettingsVariations() throws {
        let durations = [1, 5, 10, 15, 20, 25, 30]

        for duration in durations {
            var settings = PrayerSettings()
            settings.iqamahDurationMinutes = duration

            let data = try JSONEncoder().encode(settings)
            let decoded = try JSONDecoder().decode(PrayerSettings.self, from: data)

            XCTAssertEqual(decoded.iqamahDurationMinutes, duration,
                           "Durasi \(duration) menit harus persist")
        }
    }
}
