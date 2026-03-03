# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Buka dan build melalui Xcode — tidak ada CLI build toolchain.

```bash
# Build via xcodebuild (dari root repo)
xcodebuild -project AfharaAdzan.xcodeproj -scheme AfharaAdzan -configuration Debug build

# Clean build
xcodebuild -project AfharaAdzan.xcodeproj -scheme AfharaAdzan clean
```

Tidak ada unit test suite yang dikonfigurasi saat ini.

## Xcode Setup (Wajib Setelah Clone)

Dua setting harus di-set manual di Xcode Build Settings karena tidak bisa di-generate otomatis:

1. **Code Signing Entitlements** → `AfharaAdzan/AfharaAdzan.entitlements`
2. **NSLocationUsageDescription** (INFOPLIST_KEY) → teks penjelasan izin lokasi

## Arsitektur

Aplikasi macOS menu bar menggunakan **SwiftUI + `@Observable` + `@MainActor`**.

```
AfharaAdzanApp (@main)
  └── MenuBarExtra (.window style)
        ├── label: MenuBarLabel   ← ikon + nama sholat + countdown di status bar
        └── content: MenuBarView  ← popover utama
  └── Settings Scene
        └── SettingsView
```

### Alur Data

```
AppState (@Observable, @MainActor)
  ├── PrayerTimeCalculator.calculate()  ← dipanggil tiap 60 detik
  ├── LocationService (@Observable)     ← CLLocationManager wrapper
  ├── NotificationService (singleton)   ← UNUserNotificationCenter
  └── AudioService (singleton)          ← AVAudioPlayer
```

`AppState` adalah satu-satunya sumber kebenaran (single source of truth). Semua View inject via `.environment(appState)`, bukan `.environmentObject()` — karena menggunakan `@Observable`, bukan `ObservableObject`.

### State Management

- **`@Observable`** digunakan di semua class (bukan `ObservableObject`/`@Published`)
- **`@Environment(AppState.self)`** di View, bukan `@EnvironmentObject`
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** aktif di build settings — semua kode implisit `@MainActor`
- `AppState` menjalankan dua timer: `refreshTimer` (60 detik, refresh jadwal sholat) dan `countdownTimer` (1 detik, update string countdown)

### Kalkulasi Waktu Sholat

`PrayerTimeCalculator` adalah pure `struct` stateless. Parameter metode Kemenag RI:
- Fajr: 20°, Isya: 18°, Madhab Syafi'i (asrFactor = 1.0)
- Input: `Date` + `LocationModel` (lat, lon, timezone offset dalam jam)
- Output: `[PrayerTime]` dengan flag `isNext` dan `isPast`

`PrayerName.isFardhu` memfilter Syuruq dari jadwal fardhu — Syuruq tetap ada di array tapi tidak ditampilkan sebagai waktu fardhu.

### Persistence

`UserDefaults` dengan dua key:
- `"prayer_settings"` → `PrayerSettings` (JSON encoded)
- `"manual_location"` → `LocationModel` (JSON encoded, hanya disimpan jika `useAutoLocation = false`)

### File Baru

Project menggunakan `PBXFileSystemSynchronizedRootGroup` — file Swift baru yang ditambahkan ke folder `AfharaAdzan/` akan **otomatis terdeteksi Xcode** tanpa perlu edit `project.pbxproj`.

### Audio

File MP3 adzan harus diletakkan di `Resources/Sounds/` dengan nama sesuai parameter `soundName` di `AudioService.playAdzan()`. Default: `adzan_makkah.mp3`.
