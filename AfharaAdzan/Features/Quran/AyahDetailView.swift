import AppKit
import SwiftUI

struct AyahDetailView: View {

    let surah: Surah
    @Binding var arabicFontSize: Double

    @Environment(AppState.self) private var appState

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
                            appState.saveSettings()
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
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Bismillah separator
                    if showBismillah {
                        Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                            .font(.system(size: 20))
                            .foregroundStyle(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(surah.ayahs) { ayah in
                        AyahRow(ayah: ayah, arabicFontSize: arabicFontSize)
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
    let arabicFontSize: Double

    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Ayah number badge + copy button
            HStack {
                Text("\(ayah.numberInSurah)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .background(Circle().strokeBorder(.quaternary))
                Spacer()
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
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
