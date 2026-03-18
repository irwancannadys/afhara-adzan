import Foundation

struct Ayah: Codable, Identifiable, Equatable {
    let id: Int
    let surahId: Int
    let numberInSurah: Int
    let arabicText: String
    let translationId: String
    let translationEn: String
}
