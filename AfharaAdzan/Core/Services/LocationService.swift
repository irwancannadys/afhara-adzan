import Foundation
import CoreLocation
import Observation

@Observable
final class LocationService: NSObject {

    var currentLocation  : CLLocation?
    var cityName         : String = ""
    var authStatus       : CLAuthorizationStatus = .notDetermined
    var errorMessage     : String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate        = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        authStatus              = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func fetchOnce() {
        manager.requestLocation()
    }

    // MARK: - Private

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            guard let self, let place = placemarks?.first else { return }
            self.cityName = place.locality ?? place.administrativeArea ?? "Unknown"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: @preconcurrency CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc
        reverseGeocode(loc)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        if authStatus == .authorizedAlways {
            fetchOnce()
        }
    }
}
