import Foundation

enum IslamicCalendarHelper {

    private static let monthKeys: [LocalizedStringResource] = [
        "Muharram", "Safar", "Rabi'ul Awal", "Rabi'ul Akhir",
        "Jumadil Awal", "Jumadil Akhir", "Rajab", "Sya'ban",
        "Ramadan", "Syawal", "Dzulqa'dah", "Dzulhijjah"
    ]

    static func islamicDateString(for date: Date = Date()) -> String {
        let cal  = Calendar(identifier: .islamicUmmAlQura)
        let comp = cal.dateComponents([.year, .month, .day], from: date)
        guard let day = comp.day, let month = comp.month, let year = comp.year else { return "" }
        let monthName = String(localized: monthKeys[month - 1])
        return "\(day) \(monthName) \(year) H"
    }
}
