import SwiftUI

struct QuranView: View {

    @State private var selectedSurahId: Int?
    @State private var searchText = ""

    private let quranService = QuranService.shared

    var body: some View {
        HStack(spacing: 0) {
            // Left: Surah list
            SurahListView(
                surahs: quranService.surahs,
                selectedSurahId: $selectedSurahId,
                searchText: $searchText
            )
            .frame(width: 280)
            .clipped()

            Divider()

            // Right: Ayah detail
            if let surahId = selectedSurahId,
               let surah = quranService.surah(byId: surahId) {
                AyahDetailView(surah: surah)
                    .id(surahId)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                emptyState
            }
        }
        .toolbarBackground(.visible, for: .windowToolbar)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(String(localized: "Pilih surah untuk membaca"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
