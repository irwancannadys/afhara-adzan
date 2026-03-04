import SwiftUI

struct MenuBarView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            dateBannerView
            Divider()
            PrayerScheduleView()
            Divider()
            footerView
        }
        .frame(width: 300)
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

    // MARK: - Date Banner

    private var dateBannerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("Hijriah")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(islamicDateString)
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("Masehi")
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

    private var islamicDateString: String {
        let cal  = Calendar(identifier: .islamicUmmAlQura)
        let comp = cal.dateComponents([.year, .month, .day], from: Date())
        guard let day = comp.day, let month = comp.month, let year = comp.year else { return "" }
        let months = ["Muharram","Safar","Rabi'ul Awal","Rabi'ul Akhir",
                      "Jumadil Awal","Jumadil Akhir","Rajab","Sya'ban",
                      "Ramadan","Syawal","Dzulqa'dah","Dzulhijjah"]
        return "\(day) \(months[month - 1]) \(year) H"
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            if AudioService.shared.isPlaying {
                Button("Stop Adzan") {
                    AudioService.shared.stopAdzan()
                }
                .foregroundStyle(.red)
                .buttonStyle(.plain)
            }

            Spacer()

            Button {
                NSApp.focusOrOpenMainWindow { openWindow(id: "main") }
            } label: {
                Label("Buka App", systemImage: "macwindow")
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 12)
                .padding(.horizontal, 4)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Keluar", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

}

import UserNotifications
