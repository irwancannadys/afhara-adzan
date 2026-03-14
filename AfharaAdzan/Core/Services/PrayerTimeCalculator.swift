import Foundation

struct PrayerTimeCalculator {

    // MARK: - Public

    static func calculate(for date: Date, location: LocationModel, method: CalculationMethod = .kemenagRI, asrMadhab: AsrMadhab = .shafii) -> [PrayerTime] {
        let cal = Calendar.current
        let y   = cal.component(.year,  from: date)
        let m   = cal.component(.month, from: date)
        let d   = cal.component(.day,   from: date)

        let jd  = julianDate(year: y, month: m, day: d)
        let D   = jd - 2451545.0   // hari sejak J2000.0

        // Posisi matahari
        let g = mod(357.529 + 0.98560028 * D, 360)
        let q = mod(280.459 + 0.98564736 * D, 360)
        let L = mod(q + 1.915 * sin(rad(g)) + 0.020 * sin(rad(2 * g)), 360)

        let e    = 23.439 - 0.0000004 * D
        let RA   = deg(atan2(cos(rad(e)) * sin(rad(L)), cos(rad(L)))) / 15.0
        let decl = deg(asin(sin(rad(e)) * sin(rad(L))))

        // Equation of time
        let EqT = q / 15.0 - normalizeHour(RA)

        let lat = location.latitude
        let lng = location.longitude
        let tz  = location.timezone

        // Transit = waktu dzuhur (saat matahari di meridian)
        let transit = 12.0 + tz - lng / 15.0 - EqT

        let maghribHours = transit + hourAngle(-0.8333, lat: lat, dec: decl)

        // Isha: angle-based atau fixed interval (Umm al-Qura)
        let ishaHours: Double
        if let angle = method.ishaAngle {
            ishaHours = transit + hourAngle(-angle, lat: lat, dec: decl)
        } else {
            ishaHours = maghribHours + method.ishaInterval / 60.0
        }

        let rawTimes: [(PrayerName, Double)] = [
            (.fajr,    transit - hourAngle(-method.fajrAngle, lat: lat, dec: decl)),
            (.sunrise, transit - hourAngle(-0.8333,           lat: lat, dec: decl)),
            (.dhuhr,   transit),
            (.asr,     transit + asrHourAngle(lat: lat, dec: decl, shadowFactor: asrMadhab.shadowFactor)),
            (.maghrib, maghribHours),
            (.isha,    ishaHours)
        ]

        let now = Date()
        var results = rawTimes.compactMap { (name, hours) -> PrayerTime? in
            guard let time = makeDate(hours, from: date) else { return nil }
            return PrayerTime(name: name, time: time, timezoneOffset: tz, isPast: time < now)
        }

        // Tandai sholat fardhu berikutnya
        if let idx = results.firstIndex(where: { !$0.isPast && $0.name.isFardhu }) {
            results[idx].isNext = true
        }

        return results
    }

    // MARK: - Astronomy Helpers

    private static func julianDate(year: Int, month: Int, day: Int) -> Double {
        var y = year, m = month
        if m <= 2 { y -= 1; m += 12 }
        let A = y / 100
        let B = 2 - A + A / 4
        return floor(365.25 * Double(y + 4716))
             + floor(30.6001 * Double(m + 1))
             + Double(day) + Double(B) - 1524.5
    }

    private static func hourAngle(_ alt: Double, lat: Double, dec: Double) -> Double {
        let cosHA = (sin(rad(alt)) - sin(rad(lat)) * sin(rad(dec)))
                  / (cos(rad(lat)) * cos(rad(dec)))
        guard (-1.0...1.0).contains(cosHA) else { return 0 }
        return deg(acos(cosHA)) / 15.0
    }

    private static func asrHourAngle(lat: Double, dec: Double, shadowFactor: Double = 1.0) -> Double {
        let altitude = deg(atan(1.0 / (shadowFactor + tan(rad(abs(lat - dec))))))
        return hourAngle(altitude, lat: lat, dec: dec)
    }

    private static func makeDate(_ hours: Double, from base: Date) -> Date? {
        let cal = Calendar.current
        var c   = cal.dateComponents([.year, .month, .day], from: base)
        let total   = Int((hours * 60).rounded())
        c.hour      = (total / 60) % 24
        c.minute    = total % 60
        c.second    = 0
        return cal.date(from: c)
    }

    // MARK: - Math Utilities

    private static func rad(_ d: Double) -> Double { d * .pi / 180 }
    private static func deg(_ r: Double) -> Double { r * 180 / .pi }
    private static func mod(_ a: Double, _ b: Double) -> Double {
        a.truncatingRemainder(dividingBy: b)
    }
    private static func normalizeHour(_ h: Double) -> Double {
        var r = h
        while r < 0  { r += 24 }
        while r >= 24 { r -= 24 }
        return r
    }
}
