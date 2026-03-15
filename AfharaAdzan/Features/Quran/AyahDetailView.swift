import SwiftUI

struct AyahDetailView: View {

    let surah: Surah

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text(surah.arabicName)
                    .font(.largeTitle)
                Text(surah.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("\(surah.englishName) — \(surah.ayahCount) \(String(localized: "Ayat")) — \(surah.revelationType)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Divider()

            // Ayat list
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(surah.ayahs) { ayah in
                        AyahRow(ayah: ayah)
                    }
                }
                .padding(20)
            }
        }
    }
}

// MARK: - Ayah Row

private struct AyahRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let ayah: Ayah

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ayah number badge
            HStack {
                Text("\(ayah.numberInSurah)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().strokeBorder(.quaternary))
                Spacer()
            }

            // Arabic text
            Text(ayah.arabicText)
                .font(.system(size: 26))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)

            // Indonesian translation
            Text(ayah.translationId)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // English translation
            Text(ayah.translationEn)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.accentBackground(for: colorScheme).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
