import SwiftUI

struct SettingsView: View {

    @Environment(AppState.self) private var appState
    @State private var settings: PrayerSettings = PrayerSettings()
    @State private var manualCity: String = ""

    var body: some View {
        Form {

            // MARK: Notifikasi
            Section("Notifikasi") {
                Toggle("Banner Notifikasi", isOn: $settings.isNotificationEnabled)
                Toggle("Suara Adzan", isOn: $settings.isSoundEnabled)
                Toggle("Countdown di Status Bar", isOn: $settings.isCountdownEnabled)

                Stepper(
                    "Notif \(settings.notificationOffset) menit sebelum",
                    value: $settings.notificationOffset,
                    in: 0...30,
                    step: 5
                )

                Button("Stop Semua Notifikasi", role: .destructive) {
                    appState.stopAll()
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
