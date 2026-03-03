import SwiftUI

struct PrayerScheduleView: View {

    @Environment(AppState.self) private var appState

    private var fardhuPrayers: [PrayerTime] {
        appState.prayerTimes.filter { $0.name.isFardhu }
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(fardhuPrayers) { prayer in
                PrayerRowView(prayer: prayer)

                if prayer.id != fardhuPrayers.last?.id {
                    Divider()
                        .padding(.horizontal, 16)
                }
            }
        }
    }
}
