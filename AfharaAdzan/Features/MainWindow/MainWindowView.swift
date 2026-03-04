import SwiftUI

enum MainNavItem: String, CaseIterable, Identifiable {
    case schedule = "Jadwal Sholat"
    case settings = "Pengaturan"
    case about    = "Tentang"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .schedule: "clock.fill"
        case .settings: "gearshape.fill"
        case .about:    "info.circle.fill"
        }
    }
}

struct MainWindowView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: MainNavItem = .schedule

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailView
                .environment(appState)
        }
        .frame(minWidth: 640, minHeight: 460)
    }

    // MARK: - Sidebar

    private var sidebarView: some View {
        VStack(spacing: 0) {

            // Branding
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accent(for: colorScheme))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Afhara Adzan")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(appState.location.cityName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider()

            // Nav items
            List(MainNavItem.allCases, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(.sidebar)
            .padding(.top, 8)

            Spacer(minLength: 0)

            Divider()

            // Keluar
            Button(role: .destructive) {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Keluar", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .schedule: ScheduleDetailView()
        case .settings: SettingsView()
        case .about:    AboutView()
        }
    }
}

// MARK: - Schedule Detail View (desktop)

private struct ScheduleDetailView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    private var fardhuPrayers: [PrayerTime] {
        appState.prayerTimes.filter {
            $0.name.isFardhu || ($0.name == .sunrise && appState.settings.showSyuruq)
        }
    }

    private var islamicDateString: String {
        let cal   = Calendar(identifier: .islamicUmmAlQura)
        let comp  = cal.dateComponents([.year, .month, .day], from: Date())
        guard let day = comp.day, let month = comp.month, let year = comp.year else { return "" }
        let months = ["Muharram","Safar","Rabi'ul Awal","Rabi'ul Akhir",
                      "Jumadil Awal","Jumadil Akhir","Rajab","Sya'ban",
                      "Ramadan","Syawal","Dzulqa'dah","Dzulhijjah"]
        return "\(day) \(months[month - 1]) \(year) H"
    }

    var body: some View {
        VStack(spacing: 0) {

            // Date banner: Hijriah (kiri) + Masehi (kanan)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tanggal Hijriah")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(islamicDateString)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Tanggal Masehi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            Divider()

            // Sub-header: kota + countdown
            HStack(alignment: .center) {
                Text(appState.location.cityName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                if !appState.nextPrayerName.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Berikutnya")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(appState.nextPrayerName)  \(appState.countdownString)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accent(for: colorScheme))
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)

            Divider()

            // Prayer list
            List(fardhuPrayers) { prayer in
                DesktopPrayerRow(prayer: prayer)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Desktop Prayer Row

private struct DesktopPrayerRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let prayer: PrayerTime

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: prayer.name.icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundStyle(rowColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.name.rawValue)
                    .font(.body)
                    .fontWeight(prayer.isNext ? .semibold : .regular)
                Group {
                    if prayer.isPast {
                        Text("Sudah lewat")
                    } else if prayer.isNext {
                        Text("Waktu berikutnya")
                            .foregroundStyle(Color.accent(for: colorScheme))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(prayer.timeString)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(rowColor)

            Circle()
                .fill(accentColor)
                .frame(width: 8, height: 8)
                .opacity(prayer.isNext ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(prayer.isNext ? Color.accentBackground(for: colorScheme) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(prayer.isPast ? 0.65 : 1.0)
    }

    private var accentColor: Color { .accent(for: colorScheme) }

    private var rowColor: Color {
        if prayer.isNext { return accentColor }
        if prayer.isPast { return .secondary }
        return .primary
    }
}

// MARK: - About View

private struct AboutView: View {

    @Environment(\.colorScheme) private var colorScheme

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.accent(for: colorScheme))

            VStack(spacing: 6) {
                Text("Afhara Adzan")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Versi \(appVersion)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text("Pengingat waktu sholat yang sederhana untuk macOS.\nMetode Kemenag RI — Fajr 20°, Isya 18°, Madhab Syafi'i.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Divider()
                .padding(.horizontal, 80)

            Link(destination: URL(string: "https://github.com/irwancannadys/afhara-adzan")!) {
                Label("Lihat di GitHub", systemImage: "arrow.up.right.square")
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accent(for: colorScheme))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Tentang")
    }
}
