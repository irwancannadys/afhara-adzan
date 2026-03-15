import Foundation

@Observable
final class QuranService {

    static let shared = QuranService()

    private(set) var surahs: [Surah] = []
    private(set) var isLoaded = false

    private init() {
        loadData()
    }

    // MARK: - Data Loading

    private func loadData() {
        guard let url = Bundle.main.url(forResource: "quran", withExtension: "json") else {
            print("[QuranService] quran.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(QuranData.self, from: data)
            surahs = decoded.surahs
            isLoaded = true
        } catch {
            print("[QuranService] Failed to decode quran.json: \(error)")
        }
    }

    // MARK: - Queries

    func surah(byId id: Int) -> Surah? {
        surahs.first { $0.id == id }
    }

    func search(query: String) -> [Surah] {
        guard !query.isEmpty else { return surahs }
        let lowered = query.lowercased()
        return surahs.filter {
            $0.name.lowercased().contains(lowered) ||
            $0.englishName.lowercased().contains(lowered) ||
            $0.arabicName.contains(query) ||
            String($0.id) == query
        }
    }

    func searchAyahs(query: String) -> [(surah: Surah, ayah: Ayah)] {
        guard !query.isEmpty else { return [] }
        let lowered = query.lowercased()
        var results: [(surah: Surah, ayah: Ayah)] = []
        for surah in surahs {
            for ayah in surah.ayahs {
                if ayah.arabicText.contains(query) ||
                   ayah.translationId.lowercased().contains(lowered) ||
                   ayah.translationEn.lowercased().contains(lowered) {
                    results.append((surah: surah, ayah: ayah))
                }
            }
        }
        return results
    }
}

// MARK: - JSON Root

private struct QuranData: Codable {
    let surahs: [Surah]
}
