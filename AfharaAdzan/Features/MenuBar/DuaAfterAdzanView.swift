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

            Text("اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .environment(\.layoutDirection, .rightToLeft)

            Text("Allāhumma Rabba hāżihid da'watit tāmmah, waṣ-ṣalātil qā'imah, āti Muḥammadanil wasīlata wal faḍīlah, wab'aṡhu maqāman maḥmūdanil lażī wa'adtah.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(String(localized: "\"Ya Allah, Tuhan pemilik seruan yang sempurna ini dan sholat yang akan ditegakkan, karuniakanlah kepada Muhammad wasilah dan keutamaan, dan bangkitkanlah beliau ke tempat terpuji yang telah Engkau janjikan.\""))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .italic()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color.accentBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
