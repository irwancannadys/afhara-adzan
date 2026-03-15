import SwiftUI

struct SurahListView: View {

    let surahs: [Surah]
    @Binding var selectedSurahId: Int?
    @Binding var searchText: String

    private var filteredSurahs: [Surah] {
        QuranService.shared.search(query: searchText)
    }

    var body: some View {
        List(filteredSurahs, selection: $selectedSurahId) { surah in
            SurahRow(surah: surah)
                .tag(surah.id)
        }
        .listStyle(.inset)
        .searchable(
            text: $searchText,
            placement: .sidebar,
            prompt: String(localized: "Cari surah...")
        )
    }
}

// MARK: - Surah Row

private struct SurahRow: View {

    let surah: Surah

    var body: some View {
        HStack(spacing: 12) {
            Text("\(surah.id)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(Circle().strokeBorder(.quaternary))

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(surah.englishName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(surah.arabicName)
                    .font(.body)
                Text(String(localized: "\(surah.ayahCount) ayat"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
