import Foundation

struct Surah: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let arabicName: String
    let englishName: String
    let ayahCount: Int
    let revelationType: String
    let ayahs: [Ayah]
}
