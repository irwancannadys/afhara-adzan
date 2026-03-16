import SwiftUI

struct BookmarkListView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var onSelectAyah: (_ surahId: Int, _ numberInSurah: Int) -> Void

    private let quranService = QuranService.shared

    private var bookmarkedAyahs: [(surah: Surah, ayah: Ayah)] {
        appState.settings.quranBookmarks.compactMap { key in
            let parts = key.split(separator: "_")
            guard parts.count == 2,
                  let surahId = Int(parts[0]),
                  let numberInSurah = Int(parts[1]),
                  let surah = quranService.surah(byId: surahId),
                  let ayah = surah.ayahs.first(where: { $0.numberInSurah == numberInSurah })
            else { return nil }
            return (surah: surah, ayah: ayah)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image("QuranBookmarkIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.tertiary)
                Text(String(localized: "Ayat Tersimpan"))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(String(localized: "\(appState.settings.quranBookmarks.count) ayat"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Divider()

            if bookmarkedAyahs.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(bookmarkedAyahs, id: \.ayah.id) { item in
                            BookmarkRow(
                                surah: item.surah,
                                ayah: item.ayah,
                                appLanguage: appState.settings.appLanguage,
                                onTap: { onSelectAyah(item.surah.id, item.ayah.numberInSurah) },
                                onRemove: {
                                    let key = "\(item.ayah.surahId)_\(item.ayah.numberInSurah)"
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        appState.settings.quranBookmarks.removeAll { $0 == key }
                                    }
                                    appState.saveSettingsQuiet()
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .identity,
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image("QuranBookmarkIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundStyle(.tertiary)
            Text(String(localized: "Belum ada ayat tersimpan"))
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(String(localized: "Ketuk bintang pada ayat untuk menyimpan"))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Bookmark Row

private struct BookmarkRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let surah: Surah
    let ayah: Ayah
    let appLanguage: AppLanguage
    let onTap: () -> Void
    let onRemove: () -> Void

    private var localizedSurahName: String {
        switch appLanguage {
        case .id: surah.indonesianName
        case .en: surah.englishName
        case .ar: surah.englishName
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: surah name + ayah number + remove button
            HStack {
                Text("\(surah.name) : \(ayah.numberInSurah)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("(\(localizedSurahName))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "bookmark.slash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(String(localized: "Hapus bookmark"))
            }

            // Arabic text
            Text(ayah.arabicText)
                .font(.system(size: 20))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .lineLimit(2)

            // Translation
            Text(appLanguage == .en ? ayah.translationEn : ayah.translationId)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.accentBackground(for: colorScheme).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
