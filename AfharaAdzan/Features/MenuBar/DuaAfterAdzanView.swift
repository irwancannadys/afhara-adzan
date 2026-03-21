import SwiftUI

struct DuaAfterAdzanView: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "hands.and.sparkles.fill")
                    .foregroundStyle(Color.accent(for: colorScheme))
                Text(String(localized: "Doa Setelah Adzan"))
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    appState.dismissDoaBanner()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            ForEach(Array(appState.currentDuas.enumerated()), id: \.offset) { _, dua in
                VStack(spacing: 6) {
                    Text(dua.title)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accent(for: colorScheme))

                    Text(dua.arabic)
                        .font(.system(size: 13))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .environment(\.layoutDirection, .rightToLeft)

                    Text(dua.transliteration)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(dua.translation)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .italic()
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }

            }
        }
        .padding(12)
        .background(Color.accentBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
