//
//  LocationViewModel.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import Foundation
import MapKit

class LocationViewModel: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    @Published var city: String?
    
    private let locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func calculateDistance(latitude: Double, longitude: Double) -> String {
        let currentLocation = CLLocation(latitude: location?.coordinate.latitude ?? 0, longitude: location?.coordinate.longitude ?? 0)
        let targetLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = currentLocation.distance(from: targetLocation) / 1000
        return String(format: "%.2f", distance)
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        let geocoder = CLGeocoder()
        let preferredLocale = NSLocale(localeIdentifier: "en")
        geocoder.reverseGeocodeLocation(location, preferredLocale: preferredLocale as Locale) { placemarks, error in
            if error != nil {
                self.city = ""
                return
            }
            if let placemarks = placemarks?.first {
                if let cityName = placemarks.locality {
                    self.city = cityName
                }
            }
        }
    }
}
