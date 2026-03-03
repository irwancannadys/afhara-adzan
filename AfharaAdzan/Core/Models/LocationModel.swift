import Foundation

struct LocationModel: Codable, Equatable {
    var latitude : Double
    var longitude: Double
    var cityName : String
    var timezone : Double

    static let defaultLocation = LocationModel(
        latitude : -6.2088,
        longitude: 106.8456,
        cityName : "Jakarta",
        timezone : 7.0
    )
}
