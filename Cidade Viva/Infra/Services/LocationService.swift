//
//  LocationService.swift
//  CidadeViva
//
//  Serviço de gerenciamento de localização
//

import Foundation
import CoreLocation
import Combine

/// Serviço para gerenciar localização do usuário
final class LocationService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?

    // MARK: - Properties

    private let locationManager: CLLocationManager

    // MARK: - Initialization

    override init() {
        self.locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Atualiza a cada 100 metros
    }

    // MARK: - Public Methods

    /// Solicita permissão de localização
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Inicia atualização de localização
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Para atualização de localização
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// Obtém localização atual uma única vez
    func requestCurrentLocation() {
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error
        #if DEBUG
        print("❌ [LocationService] Error: \(error.localizedDescription)")
        #endif
    }
}
