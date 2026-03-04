# Changelog

All notable changes to Afhara Adzan are documented here.

---

## [1.3.0]

### Added
- **Metode hisab** — pilih antara Kemenag RI, Muslim World League, ISNA, Umm al-Qura, atau Egyptian. Parameter Fajr/Isha ditampilkan dinamis di Settings
- **Tampilkan Syuruq** — toggle opsional di Settings untuk menampilkan Syuruq di daftar jadwal (tanpa notifikasi/adzan)
- **Multiple suara adzan** — bundling 2 suara tambahan (Makkah, Madinah)
- **GitHub Actions release workflow** — build `.dmg` otomatis setiap push tag `v*`
- **Build script lokal** — `scripts/build_dmg.sh` untuk generate DMG tanpa Xcode GUI

### Fixed
- Auto-open desktop window on launch now works correctly
- Prevent duplicate windows — clicking "Buka App" focuses the existing window instead of opening a new one
- Theme applied consistently from startup via `AppDelegate.applicationDidFinishLaunching` (no longer flickers on first open)
- Notifikasi dan adzan tidak lagi double-sound (system ding + MP3 bersamaan)
- Suara adzan selalu sesuai pilihan terbaru user, bukan pilihan saat app pertama dibuka
- Jadwal sholat otomatis refresh saat pergantian hari tanpa perlu restart app
- `DateFormatter` dijadikan static — tidak lagi dibuat ulang tiap detik
- `PrayerTime.id` pakai `PrayerName` — SwiftUI tidak re-render semua row tiap 60 detik

---

## [0.3.0]

### Added
- **App Icon** — custom icon in all required sizes (16×16 to 1024×1024)
- **Launch at Login** — toggle in Settings menggunakan `SMAppService`
- **Per-prayer notification toggle** — mute/unmute notifikasi per waktu sholat (Subuh, Dzuhur, Ashar, Maghrib, Isya)
- **Sound picker** — pilih file adzan MP3 dari Settings, dengan tombol Preview dan Stop
- **About screen** — versi aplikasi, deskripsi, dan link GitHub

### Fixed
- Waktu sholat dibulatkan dengan benar (`rounded()`) agar sesuai tabel Kemenag RI — sebelumnya selisih 1 menit dari referensi resmi

---

## [0.2.0]

### Added
- **Theme switcher** — Sistem / Terang / Gelap via segmented picker di Settings
- **Dual date display** — Hijriah (Umm al-Qura) dan Masehi ditampilkan di menu bar popup dan desktop app
- **Green accent color** — warna hijau `#007200` untuk light mode, orange untuk dark mode
- **Soft background highlight** — `#F0F7EE` untuk row aktif di light mode

### Fixed
- Menu bar popup background sekarang putih konsisten (bukan translucent grey)
- Theme menu bar popup langsung sinkron dengan tema desktop tanpa perlu buka window dulu
- `Color.accent(for:)` dipanggil eksplisit untuk resolve ShapeStyle inference error

---

## [0.1.0]

### Added
- **Menu bar app** — ikon bulan + nama sholat berikutnya + countdown di status bar
- **Jadwal sholat** — kalkulasi menggunakan metode Kemenag RI (Fajr 20°, Isya 18°, Madhab Syafi'i)
- **Lokasi otomatis** — via GPS (`CLLocationManager`)
- **Lokasi manual** — input nama kota dengan geocoding
- **Notifikasi banner** — dengan opsi offset menit sebelum waktu sholat
- **Countdown di status bar** — bisa diaktifkan/nonaktifkan
- **Label timezone** — WIB / WITA / WIT otomatis sesuai lokasi
- **Dot alignment fix** — indikator sholat berikutnya tidak menggeser kolom waktu
- **Padding sidebar** fix — item "Jadwal Sholat" tidak mepet ke divider
