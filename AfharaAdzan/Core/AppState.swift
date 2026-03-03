import Foundation
import CoreLocation
import Observation

@Observable
@MainActor
final class AppState {

    // MARK: - Published State

    var prayerTimes    : [PrayerTime]   = []
    var nextPrayer     : PrayerTime?
    var settings       : PrayerSettings = PrayerSettings()
    var location       : LocationModel  = .defaultLocation

    // Status bar display
    var countdownString: String = ""
    var nextPrayerName : String = ""

    // MARK: - Private

    private let locationService = LocationService()
    private var refreshTimer   : Timer?
    private var countdownTimer : Timer?
    private var audioTimers    : [Timer] = []

    // MARK: - Init

    init() {
        loadFromStorage()
        refreshPrayerTimes()
        startRefreshTimer()
        startCountdownTimer()
        observeLocation()
    }

    // MARK: - Prayer Times

    func refreshPrayerTimes() {
        prayerTimes = PrayerTimeCalculator.calculate(for: Date(), location: location)
        nextPrayer  = prayerTimes.first { $0.isNext }

        if settings.isNotificationEnabled {
            NotificationService.shared.schedule(prayerTimes: prayerTimes, settings: settings)
        }

        scheduleAudioTimers()
        updateCountdown()
    }

    // MARK: - Audio Timers

    private func scheduleAudioTimers() {
        audioTimers.forEach { $0.invalidate() }
        audioTimers.removeAll()

        guard settings.isSoundEnabled else { return }

        let upcoming = prayerTimes.filter { $0.name.isFardhu && !$0.isPast }
        for prayer in upcoming {
            let delay = prayer.time.timeIntervalSinceNow
            guard delay > 0 else { continue }

            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, self.settings.isSoundEnabled else { return }
                    AudioService.shared.playAdzan()
                }
            }
            audioTimers.append(timer)
        }
    }

    // MARK: - Timers

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refreshPrayerTimes() }
        }
    }

    private func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.updateCountdown() }
        }
    }

    private func updateCountdown() {
        guard let next = nextPrayer else {
            countdownString = ""
            nextPrayerName  = ""
            return
        }

        let diff = next.time.timeIntervalSinceNow
        guard diff > 0 else { refreshPrayerTimes(); return }

        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        let s = Int(diff) % 60

        nextPrayerName  = next.name.rawValue
        countdownString = h > 0
            ? String(format: "%dj %02dm", h, m)
            : String(format: "%02dm %02ds", m, s)
    }

    // MARK: - Location

    private func observeLocation() {
        guard settings.useAutoLocation else { return }
        locationService.requestPermission()

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard let loc = self.locationService.currentLocation,
                      !self.locationService.cityName.isEmpty else { return }

                let tz = Double(TimeZone.current.secondsFromGMT() / 3600)
                let newLocation = LocationModel(
                    latitude : loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    cityName : self.locationService.cityName,
                    timezone : tz
                )
                if newLocation != self.location {
                    self.location = newLocation
                    self.refreshPrayerTimes()
                }
                timer.invalidate()
            }
        }
    }

    func requestLocation() {
        locationService.requestPermission()
        locationService.fetchOnce()
    }

    // MARK: - Stop All

    func stopAll() {
        NotificationService.shared.cancelAll()
        AudioService.shared.stopAdzan()
    }

    // MARK: - Persistence

    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "prayer_settings")
        }
        if !settings.useAutoLocation,
           let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: "manual_location")
        }
        refreshPrayerTimes()
    }

    private func loadFromStorage() {
        if let data    = UserDefaults.standard.data(forKey: "prayer_settings"),
           let decoded = try? JSONDecoder().decode(PrayerSettings.self, from: data) {
            settings = decoded
        }
        if !settings.useAutoLocation,
           let data    = UserDefaults.standard.data(forKey: "manual_location"),
           let decoded = try? JSONDecoder().decode(LocationModel.self, from: data) {
            location = decoded
        }
    }
}
