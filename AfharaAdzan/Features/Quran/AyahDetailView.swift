import AppKit
import SwiftUI

struct AyahDetailView: View {

    let surah: Surah
    @Binding var arabicFontSize: Double
    @Binding var scrollToAyah: Int?

    @Environment(AppState.self) private var appState
    @State private var highlightedAyah: Int?
    @State private var scrollRequestId = UUID()

    private var showBismillah: Bool {
        surah.id != 1 && surah.id != 9
    }

    private var localizedMeaning: String {
        switch appState.settings.appLanguage {
        case .id: surah.indonesianName
        case .en: surah.englishName
        case .ar: surah.englishName
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Text(surah.arabicName)
                    .font(.largeTitle)
                Text(surah.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("\(localizedMeaning) — \(surah.ayahCount) \(String(localized: "Ayat")) — \(surah.revelationType)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Font size slider
                HStack(spacing: 8) {
                    Image(systemName: "textformat.size.smaller")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Slider(value: $arabicFontSize, in: 18...40, step: 1)
                        .frame(width: 120)
                        .onChange(of: arabicFontSize) {
                            appState.saveSettingsQuiet()
                        }
                    Image(systemName: "textformat.size.larger")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            Divider()

            // Ayat list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Bismillah separator
                        if showBismillah {
                            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                                .font(.system(size: 20))
                                .foregroundStyle(.primary.opacity(0.85))
                                .frame(maxWidth: .infinity)
                        }
                        ForEach(surah.ayahs) { ayah in
                            let key = "\(ayah.surahId)_\(ayah.numberInSurah)"
                            AyahRow(
                                ayah: ayah,
                                arabicFontSize: arabicFontSize,
                                isHighlighted: highlightedAyah == ayah.numberInSurah,
                                isBookmarked: appState.settings.quranBookmarks.contains(key),
                                onToggleBookmark: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if let index = appState.settings.quranBookmarks.firstIndex(of: key) {
                                            appState.settings.quranBookmarks.remove(at: index)
                                        } else {
                                            appState.settings.quranBookmarks.insert(key, at: 0)
                                        }
                                    }
                                    appState.saveSettingsQuiet()
                                }
                            )
                            .id(ayah.numberInSurah)
                        }
                    }
                    .padding(20)
                }
                .onAppear {
                    scrollToTarget(proxy: proxy)
                }
                .onChange(of: scrollToAyah) {
                    scrollToTarget(proxy: proxy)
                }
            }
        }
    }

    private func scrollToTarget(proxy: ScrollViewProxy) {
        guard let target = scrollToAyah else { return }
        let requestId = UUID()
        scrollRequestId = requestId
        // Clear any previous highlight immediately
        highlightedAyah = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            guard scrollRequestId == requestId else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                proxy.scrollTo(target, anchor: .top)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                guard scrollRequestId == requestId else { return }
                withAnimation(.easeIn(duration: 0.2)) {
                    highlightedAyah = target
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    guard scrollRequestId == requestId else { return }
                    withAnimation(.easeOut(duration: 0.5)) {
                        highlightedAyah = nil
                    }
                }
            }
            scrollToAyah = nil
        }
    }
}

// MARK: - Ayah Row

private struct AyahRow: View {

    @Environment(\.colorScheme) private var colorScheme

    let ayah: Ayah
    let arabicFontSize: Double
    var isHighlighted: Bool = false
    var isBookmarked: Bool = false
    var onToggleBookmark: () -> Void = {}

    @State private var showCopied = false
    @State private var starScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ayah number badge + bookmark + copy button
            HStack {
                Text("\(ayah.numberInSurah)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().strokeBorder(.quaternary))
                Spacer()
                Button {
                    onToggleBookmark()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                        starScale = 1.8
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                            starScale = 1.0
                        }
                    }
                } label: {
                    Image(systemName: isBookmarked ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(isBookmarked ? .yellow : .secondary)
                        .scaleEffect(starScale)
                        .animation(.easeInOut(duration: 0.2), value: isBookmarked)
                }
                .buttonStyle(.plain)
                .help(String(localized: "Bookmark ayat"))
                Button {
                    let text = """
                    \(ayah.arabicText)

                    \(ayah.translationId)

                    \(ayah.translationEn)
                    """
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    showCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showCopied = false
                    }
                } label: {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(showCopied ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .help(String(localized: "Salin ayat"))
            }

            // Arabic text
            Text(ayah.arabicText)
                .font(.system(size: arabicFontSize))
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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.accent(for: colorScheme), lineWidth: isHighlighted ? 2 : 0)
                .opacity(isHighlighted ? 1 : 0)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
