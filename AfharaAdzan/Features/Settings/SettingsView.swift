import SwiftUI

struct SettingsView: View {

    @Environment(AppState.self) private var appState
    @State private var settings: PrayerSettings = PrayerSettings()
    @State private var manualCity: String = ""

    private var availableSounds: [String] {
        Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil)
            .map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
            .sorted()
    }

    private var fardhuPrayerNames: [PrayerName] {
        PrayerName.allCases.filter { $0.isFardhu }
    }

    var body: some View {
        Form {

            // MARK: Tampilan
            Section("Tampilan") {
                Picker("Tema", selection: $settings.appTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Label(theme.rawValue, systemImage: theme.icon).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: Notifikasi
            Section("Notifikasi") {
                Toggle("Banner Notifikasi", isOn: $settings.isNotificationEnabled)
                Toggle("Countdown di Status Bar", isOn: $settings.isCountdownEnabled)

                Stepper(
                    "Notif \(settings.notificationOffset) menit sebelum",
                    value: $settings.notificationOffset,
                    in: 0...30,
                    step: 5
                )
                .disabled(!settings.isNotificationEnabled)

                Button("Stop Semua Notifikasi", role: .destructive) {
                    appState.stopAll()
                }
            }

            // MARK: Notifikasi per Sholat
            Section("Notifikasi per Waktu Sholat") {
                ForEach(fardhuPrayerNames) { prayer in
                    Toggle(prayer.rawValue, isOn: Binding(
                        get: { !settings.mutedPrayers.contains(prayer) },
                        set: { enabled in
                            if enabled { settings.mutedPrayers.remove(prayer) }
                            else       { settings.mutedPrayers.insert(prayer) }
                        }
                    ))
                }
            }
            .disabled(!settings.isNotificationEnabled)

            // MARK: Suara Adzan
            Section("Suara Adzan") {
                Toggle("Aktifkan Suara", isOn: $settings.isSoundEnabled)

                if !availableSounds.isEmpty {
                    Picker("Pilih Suara", selection: $settings.selectedSound) {
                        ForEach(availableSounds, id: \.self) { sound in
                            Text(sound.replacingOccurrences(of: "_", with: " ").capitalized)
                                .tag(sound)
                        }
                    }
                    .disabled(!settings.isSoundEnabled)

                    HStack {
                        if AudioService.shared.isPlaying {
                            Button(role: .destructive) {
                                AudioService.shared.stopAdzan()
                            } label: {
                                Label("Stop", systemImage: "stop.fill")
                            }
                        } else {
                            Button {
                                AudioService.shared.playAdzan(soundName: settings.selectedSound)
                            } label: {
                                Label("Preview", systemImage: "play.fill")
                            }
                        }
                    }
                    .disabled(!settings.isSoundEnabled)
                }
            }

            // MARK: Lokasi
            Section("Lokasi") {
                Toggle("Lokasi Otomatis (GPS)", isOn: $settings.useAutoLocation)
                    .onChange(of: settings.useAutoLocation) { _, useAuto in
                        if useAuto { appState.requestLocation() }
                    }

                if !settings.useAutoLocation {
                    HStack {
                        TextField("Nama kota", text: $manualCity)
                        Button("Simpan") {
                            saveManualCity()
                        }
                        .disabled(manualCity.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                LabeledContent("Lokasi saat ini", value: appState.location.cityName)
                    .foregroundStyle(.secondary)
            }

            // MARK: Sistem
            Section("Sistem") {
                Toggle("Buka saat Login", isOn: $settings.launchAtLogin)
            }

            // MARK: Metode Hisab
            Section("Metode Hisab") {
                LabeledContent("Metode",  value: "Kemenag RI")
                LabeledContent("Fajr",   value: "20\u{00B0}")
                LabeledContent("Isya",   value: "18\u{00B0}")
                LabeledContent("Madhab", value: "Syafi\u{2019}i")
            }

        }
        .formStyle(.grouped)
        .navigationTitle("Pengaturan")
        .onAppear {
            settings   = appState.settings
            manualCity = appState.location.cityName
        }
        .onChange(of: settings) { _, newVal in
            appState.settings = newVal
            appState.saveSettings()
        }
    }

    private func saveManualCity() {
        // Lookup koordinat kota secara geocoding
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(manualCity) { placemarks, _ in
            guard let place = placemarks?.first,
                  let coord = place.location?.coordinate else { return }
            Task { @MainActor in
                let tz = Double(TimeZone.current.secondsFromGMT() / 3600)
                appState.location = LocationModel(
                    latitude : coord.latitude,
                    longitude: coord.longitude,
                    cityName : place.locality ?? manualCity,
                    timezone : tz
                )
                appState.saveSettings()
            }
        }
    }
}

// CLGeocoder butuh import CoreLocation
import CoreLocation
