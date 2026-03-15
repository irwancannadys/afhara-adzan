import SwiftUI

struct SettingsView: View {

    @Environment(AppState.self) private var appState
    @State private var settings: PrayerSettings = PrayerSettings()
    @State private var manualCity: String = ""
    @State private var showRestartAlert: Bool = false
    @State private var showMadhabAlert: Bool = false
    @State private var didAppear: Bool = false

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
            Section(String(localized: "Tampilan")) {
                Picker(String(localized: "Tema"), selection: $settings.appTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Label(theme.localizedName, systemImage: theme.icon).tag(theme)
                    }
                }
                .pickerStyle(.segmented)

                Toggle(String(localized: "Tampilkan Syuruq"), isOn: $settings.showSyuruq)
            }

            // MARK: Notifikasi
            Section(String(localized: "Notifikasi")) {
                Toggle(String(localized: "Banner Notifikasi"), isOn: $settings.isNotificationEnabled)
                Toggle(String(localized: "Countdown di Status Bar"), isOn: $settings.isCountdownEnabled)

                Stepper(
                    String(localized: "Notif \(settings.notificationOffset) menit sebelum"),
                    value: $settings.notificationOffset,
                    in: 0...30,
                    step: 5
                )
                .disabled(!settings.isNotificationEnabled)

                Button(String(localized: "Stop Semua Notifikasi"), role: .destructive) {
                    appState.stopAll()
                }
            }

            // MARK: Notifikasi per Sholat
            Section(String(localized: "Notifikasi per Waktu Sholat")) {
                ForEach(fardhuPrayerNames) { prayer in
                    Toggle(prayer.localizedName, isOn: Binding(
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
            Section(String(localized: "Suara Adzan")) {
                Toggle(String(localized: "Aktifkan Suara"), isOn: $settings.isSoundEnabled)

                if !availableSounds.isEmpty {
                    Picker(String(localized: "Pilih Suara"), selection: $settings.selectedSound) {
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

            // MARK: Doa Setelah Adzan
            Section(String(localized: "Doa Setelah Adzan")) {
                Toggle(String(localized: "Tampilkan Doa Setelah Adzan"), isOn: $settings.showDuaAfterAdzan)
                Stepper(
                    String(localized: "Auto-dismiss \(settings.duaDismissSeconds) detik"),
                    value: $settings.duaDismissSeconds,
                    in: 0...120,
                    step: 5
                )
                .disabled(!settings.showDuaAfterAdzan)

                if settings.duaDismissSeconds == 0 {
                    Text(String(localized: "Doa tidak akan otomatis hilang"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Iqamah
            Section("Iqamah") {
                Toggle(String(localized: "Aktifkan Iqamah Timer"), isOn: $settings.iqamahEnabled)
                Stepper(
                    String(localized: "Durasi \(settings.iqamahDurationMinutes) menit"),
                    value: $settings.iqamahDurationMinutes,
                    in: 1...30,
                    step: 1
                )
                .disabled(!settings.iqamahEnabled)
            }

            // MARK: Lokasi
            Section(String(localized: "Lokasi")) {
                Toggle(String(localized: "Lokasi Otomatis (GPS)"), isOn: $settings.useAutoLocation)
                    .onChange(of: settings.useAutoLocation) { _, useAuto in
                        if useAuto { appState.requestLocation() }
                    }

                if !settings.useAutoLocation {
                    HStack {
                        TextField(String(localized: "Nama kota"), text: $manualCity)
                        Button(String(localized: "Simpan")) {
                            saveManualCity()
                        }
                        .disabled(manualCity.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                LabeledContent(String(localized: "Lokasi saat ini"), value: appState.location.cityName)
                    .foregroundStyle(.secondary)
            }

            // MARK: Sistem
            Section(String(localized: "Sistem")) {
                Toggle(String(localized: "Buka saat Login"), isOn: $settings.launchAtLogin)
            }

            // MARK: Bahasa
            Section(String(localized: "Bahasa")) {
                Picker(String(localized: "Bahasa Aplikasi"), selection: $settings.appLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .onChange(of: settings.appLanguage) { _, newLang in
                    UserDefaults.standard.set([newLang.localeIdentifier], forKey: "AppleLanguages")
                    UserDefaults.standard.synchronize()
                    showRestartAlert = true
                }

                Text(String(localized: "Perubahan bahasa memerlukan restart aplikasi"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .alert(String(localized: "Restart Aplikasi"), isPresented: $showRestartAlert) {
                Button(String(localized: "Restart Sekarang")) {
                    // Save settings dulu, lalu restart
                    appState.settings = settings
                    appState.saveSettings()
                    let task = Process()
                    task.launchPath = "/usr/bin/open"
                    task.arguments = ["-n", Bundle.main.bundlePath]
                    task.launch()
                    NSApplication.shared.terminate(nil)
                }
                Button(String(localized: "Nanti"), role: .cancel) { }
            } message: {
                Text(String(localized: "Aplikasi perlu di-restart agar perubahan bahasa diterapkan. Restart sekarang?"))
            }

            // MARK: Metode Hisab
            Section(String(localized: "Metode Hisab")) {
                Picker(String(localized: "Metode"), selection: $settings.calculationMethod) {
                    ForEach(CalculationMethod.allCases, id: \.self) { method in
                        Text(method.localizedName).tag(method)
                    }
                }

                LabeledContent("Fajr", value: String(format: "%.1f°", settings.calculationMethod.fajrAngle))

                if let ishaAngle = settings.calculationMethod.ishaAngle {
                    LabeledContent(String(localized: "Isya"), value: String(format: "%.1f°", ishaAngle))
                } else {
                    LabeledContent(String(localized: "Isya"), value: String(localized: "Maghrib + \(Int(settings.calculationMethod.ishaInterval)) menit"))
                }

                Picker("Madhab", selection: $settings.asrMadhab) {
                    ForEach(AsrMadhab.allCases, id: \.self) { madhab in
                        Text(madhab.rawValue).tag(madhab)
                    }
                }
                .onChange(of: settings.asrMadhab) { _, _ in
                    guard didAppear else { return }
                    showMadhabAlert = true
                }

                if let asrTime = appState.prayerTimes.first(where: { $0.name == .asr }) {
                    LabeledContent(String(localized: "Ashar hari ini"), value: asrTime.timeString)
                        .foregroundStyle(.secondary)
                }
            }
            .alert(String(localized: "Madhab Diubah"), isPresented: $showMadhabAlert) {
                Button("OK") { }
            } message: {
                if let asrTime = appState.prayerTimes.first(where: { $0.name == .asr }) {
                    Text(String(localized: "Madhab berhasil diubah ke \(settings.asrMadhab.rawValue). Waktu Ashar hari ini: \(asrTime.timeString)"))
                }
            }

        }
        .formStyle(.grouped)
        .navigationTitle(String(localized: "Pengaturan"))
        .onAppear {
            settings   = appState.settings
            manualCity = appState.location.cityName
            DispatchQueue.main.async { didAppear = true }
        }
        .onChange(of: settings) { _, newVal in
            appState.settings = newVal
            appState.saveSettings()
        }
    }

    private func saveManualCity() {
        let geocoder = CLGeocoder()
        Task {
            guard let placemarks = try? await geocoder.geocodeAddressString(manualCity),
                  let place = placemarks.first,
                  let coord = place.location?.coordinate else { return }
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

// CLGeocoder butuh import CoreLocation
import CoreLocation
