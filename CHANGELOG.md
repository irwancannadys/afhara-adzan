# Changelog

All notable changes to Afhara Adzan are documented here.

---

## [1.4.0]

### Added
- **Asr madhab selector** — choose between Syafi'i (shadow factor 1×) and Hanafi (shadow factor 2×) in Settings, with confirmation alert showing updated Asr time
- **Iqamah countdown timer** — configurable countdown (default 5 minutes) starts automatically after adzan finishes, displayed in both menu bar and desktop dashboard
- **Doa after adzan banner** — Arabic text, transliteration, and Indonesian translation shown in menu bar and desktop dashboard after adzan, auto-dismisses before iqamah ends
- **Per-prayer mute for adzan sound** — individually mute adzan audio per prayer (separate from notification toggle)
- **Foreground notification support** — macOS notifications now display even when the app is in the foreground via `UNUserNotificationCenterDelegate`
- **Iqamah notification** — system notification fires when iqamah countdown reaches zero
- **Simulate adzan button** — debug-only button in Settings to test the full adzan → doa → iqamah flow without waiting for prayer time
- **Multi-language support** — language selector (Indonesian / English) with restart prompt
- **Unit tests** — 51 tests covering madhab calculation, notification scheduling, iqamah state machine, and end-to-end simulation

### Fixed
- Notification permission now properly requested on first launch
- Doa text no longer truncated in menu bar — transliteration and translation wrap correctly
- Iqamah countdown text displayed in red for better visibility

---

## [1.3.0]

### Added
- **Calculation method selector** — choose between Kemenag RI, Muslim World League, ISNA, Umm al-Qura, or Egyptian. Fajr/Isha parameters displayed dynamically in Settings
- **Syuruq toggle** — optional toggle in Settings to show Syuruq in the schedule (no notification or audio)
- **Multiple adzan sounds** — bundled 2 additional sounds (Makkah, Madinah)
- **GitHub Actions release workflow** — auto-builds `.dmg` on every `v*` tag push
- **Local build script** — `scripts/build_dmg.sh` to generate DMG without Xcode GUI

### Fixed
- Prayer schedule now auto-refreshes at midnight without requiring an app restart
- Notifications and adzan no longer double-sound (system ding + MP3 simultaneously)
- Adzan sound always reflects the latest user selection, not the one set when the app first launched
- Auto-open desktop window on launch now works correctly
- Prevent duplicate windows — clicking "Open App" focuses the existing window instead of opening a new one
- Theme applied consistently from startup via `AppDelegate.applicationDidFinishLaunching` (no longer flickers on first open)
- `DateFormatter` is now static — no longer re-initialized every second
- `PrayerTime.id` uses `PrayerName` — SwiftUI no longer re-renders all rows every 60 seconds

---

## [0.3.0]

### Added
- **App Icon** — custom icon in all required sizes (16×16 to 1024×1024)
- **Launch at Login** — toggle in Settings using `SMAppService`
- **Per-prayer notification toggle** — mute/unmute notifications per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha)
- **Sound picker** — select adzan MP3 from Settings, with Preview and Stop buttons
- **About screen** — app version, description, and GitHub link

### Fixed
- Prayer times now correctly rounded (`rounded()`) to match official Kemenag RI tables — previously off by 1 minute

---

## [0.2.0]

### Added
- **Theme switcher** — System / Light / Dark via segmented picker in Settings
- **Dual date display** — Hijri (Umm al-Qura) and Gregorian shown in both menu bar popup and desktop app
- **Green accent color** — `#007200` for light mode, orange for dark mode
- **Soft background highlight** — `#F0F7EE` for active row in light mode

### Fixed
- Menu bar popup background now consistently white (not translucent grey)
- Theme in menu bar popup now syncs immediately with desktop theme without opening the window first
- `Color.accent(for:)` called explicitly to resolve ShapeStyle inference error

---

## [0.1.0]

### Added
- **Menu bar app** — moon icon + next prayer name + countdown in the status bar
- **Prayer schedule** — calculated using Kemenag RI method (Fajr 20°, Isha 18°, Shafi'i madhab)
- **Auto location** — via GPS (`CLLocationManager`)
- **Manual location** — city name input with geocoding
- **Banner notifications** — with optional minute offset before prayer time
- **Countdown toggle** — show/hide countdown in the status bar
- **Timezone label** — WIB / WITA / WIT displayed automatically based on location
- **Dot alignment fix** — next prayer indicator no longer shifts the time column
- **Sidebar padding fix** — "Prayer Schedule" item no longer clipped by the divider
