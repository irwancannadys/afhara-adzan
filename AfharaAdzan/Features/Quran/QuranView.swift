import SwiftUI

struct QuranView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSurahId: Int?
    @State private var searchText = ""
    @State private var showBookmarks = false
    @State private var scrollToAyah: Int?

    private let quranService = QuranService.shared

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            // Left: Surah list
            SurahListView(
                surahs: quranService.surahs,
                selectedSurahId: $selectedSurahId,
                searchText: $searchText,
                showBookmarks: showBookmarks,
                onSelectSurah: { _ in showBookmarks = false }
            )
            .frame(width: 280)
            .clipped()

            Divider()

            // Right: Bookmark list or Ayah detail
            if showBookmarks {
                BookmarkListView { surahId, numberInSurah in
                    // Reset first so onChange fires even for the same surah
                    scrollToAyah = nil
                    selectedSurahId = surahId
                    showBookmarks = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        scrollToAyah = numberInSurah
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let surahId = selectedSurahId,
               let surah = quranService.surah(byId: surahId) {
                AyahDetailView(
                    surah: surah,
                    arabicFontSize: $appState.settings.quranArabicFontSize,
                    scrollToAyah: $scrollToAyah
                )
                .id(surahId)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                emptyState
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showBookmarks.toggle()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: showBookmarks ? "bookmark.fill" : "bookmark")
                            .font(.body)
                        if appState.settings.quranBookmarks.count > 0 {
                            Text("\(appState.settings.quranBookmarks.count)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .id("badge_\(appState.settings.quranBookmarks.count)")
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color.accent(for: colorScheme)))
                                .offset(x: 8, y: -6)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: appState.settings.quranBookmarks.count)
                        }
                    }
                }
                .help("Bookmark (\(appState.settings.quranBookmarks.count))")
            }
        }
        .toolbarBackground(.visible, for: .windowToolbar)
        .onAppear {
            if let lastId = appState.settings.quranLastSurahId {
                selectedSurahId = lastId
            }
        }
        .onChange(of: selectedSurahId) { _, newValue in
            appState.settings.quranLastSurahId = newValue
            appState.saveSettings()
        }
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
