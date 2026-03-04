import SwiftUI

struct PrayerRowView: View {

    @Environment(\.colorScheme) private var colorScheme

    let prayer: PrayerTime

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.name.icon)
                .frame(width: 20)
                .foregroundStyle(rowColor)

            Text(prayer.name.rawValue)
                .fontWeight(prayer.isNext ? .semibold : .regular)
                .foregroundStyle(prayer.isPast ? .secondary : .primary)

            Spacer()

            Text(prayer.timeString)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(rowColor)

            Circle()
                .fill(accentColor)
                .frame(width: 6, height: 6)
                .opacity(prayer.isNext ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
        .background(prayer.isNext ? accentColor.opacity(0.08) : Color.clear)
        .opacity(prayer.isPast ? 0.65 : 1.0)
    }

    private var accentColor: Color { .accent(for: colorScheme) }

    private var rowColor: Color {
        if prayer.isNext { return accentColor }
        if prayer.isPast { return .secondary }
        return .primary
    }
}
