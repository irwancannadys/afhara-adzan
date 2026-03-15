import SwiftUI

struct SurahListView: View {

    let surahs: [Surah]
    @Binding var selectedSurahId: Int?
    @Binding var searchText: String

    private var filteredSurahs: [Surah] {
        QuranService.shared.search(query: searchText)
    }

    var body: some View {
        List(filteredSurahs) { surah in
            SurahRow(surah: surah, isSelected: selectedSurahId == surah.id)
                .contentShape(Rectangle())
                .onTapGesture { selectedSurahId = surah.id }
                .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
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

    @Environment(\.colorScheme) private var colorScheme

    let surah: Surah
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("\(surah.id)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                .frame(width: 28, height: 28)
                .background(
                    Circle().strokeBorder(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.3))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.name)
                    .font(.body)
                    .fontWeight(.medium)
                Text(surah.englishName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(surah.arabicName)
                    .font(.body)
                Text(String(localized: "\(surah.ayahCount) ayat"))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
            }
        }
        .foregroundStyle(isSelected ? .white : .primary)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accent(for: colorScheme) : .clear)
        )
    }
}
