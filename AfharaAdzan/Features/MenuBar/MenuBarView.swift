import SwiftUI

struct MenuBarView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()

            // Doa setelah adzan banner
            if appState.showDoaBanner {
                DuaAfterAdzanView()
                Divider()
            }

            // Iqamah countdown banner
            if case .countdown(let prayerName, let remaining) = appState.iqamahState {
                iqamahBannerView(prayerName: prayerName, remaining: remaining)
                Divider()
            }

            dateBannerView
            Divider()
            PrayerScheduleView()
            Divider()
            footerView
        }
        .frame(width: 360)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Afhara Adzan")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(appState.location.cityName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !appState.nextPrayerName.isEmpty {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(appState.nextPrayerName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(appState.countdownString)
                        .font(.system(.callout, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accent(for: colorScheme))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Iqamah Banner

    private func iqamahBannerView(prayerName: String, remaining: Int) -> some View {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return HStack {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(Color.accent(for: colorScheme))
            VStack(alignment: .leading, spacing: 1) {
                Text(String(localized: "Iqamah \(prayerName)"))
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(String(format: "%02d:%02d", minutes, seconds))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.accentBackground(for: colorScheme))
    }

    // MARK: - Date Banner

    private var dateBannerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(String(localized: "Hijriah"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(IslamicCalendarHelper.islamicDateString())
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text(String(localized: "Masehi"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(Date().formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if AudioService.shared.isPlaying {
                Button(String(localized: "Stop Adzan")) {
                    AudioService.shared.stopAdzan()
                }
                .foregroundStyle(.red)
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                NSApp.focusOrOpenMainWindow { openWindow(id: "main") }
            } label: {
                Label(String(localized: "Buka App"), systemImage: "macwindow")
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 12)
                .padding(.horizontal, 4)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label(String(localized: "Keluar"), systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

}

import UserNotifications
