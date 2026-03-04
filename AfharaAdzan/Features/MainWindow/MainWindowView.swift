import SwiftUI

enum MainNavItem: String, CaseIterable, Identifiable {
    case schedule = "Jadwal Sholat"
    case settings = "Pengaturan"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .schedule: "clock.fill"
        case .settings: "gearshape.fill"
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
                    .foregroundStyle(.accent(for: colorScheme))
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
        }
    }
}

// MARK: - Schedule Detail View (desktop)

private struct ScheduleDetailView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    private var fardhuPrayers: [PrayerTime] {
        appState.prayerTimes.filter { $0.name.isFardhu }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Header tanggal & countdown
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(appState.location.cityName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !appState.nextPrayerName.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Berikutnya")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(appState.nextPrayerName)  \(appState.countdownString)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent(for: colorScheme))
                            .monospacedDigit()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

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
                            .foregroundStyle(.accent(for: colorScheme))
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
        .background(prayer.isNext ? accentColor.opacity(0.07) : Color.clear)
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
