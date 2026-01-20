import Foundation
import CoreLocation
import Combine

/// Serviço para gerenciar localização do usuário
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    // MARK: - Published Properties

    /// Localização atual do usuário
    @Published var currentLocation: CLLocation?

    /// Status de autorização
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// Indica se está buscando localização
    @Published var isUpdatingLocation = false

    /// Último erro ocorrido
    @Published var error: Error?

    // MARK: - Properties

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    // MARK: - Coordenadas de Niterói, RJ

    /// Centro de Niterói para centralizar o mapa
    static let niteroiCenter = CLLocationCoordinate2D(
        latitude: -22.8839,
        longitude: -43.1034
    )

    /// Span padrão para visualização do mapa
    static let defaultLatitudeDelta: Double = 0.05
    static let defaultLongitudeDelta: Double = 0.05

    // MARK: - Initialization

    private override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50 // Atualiza a cada 50 metros
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Authorization

    /// Solicita permissão para acessar localização
    func requestAuthorization() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            error = LocationError.permissionDenied
        default:
            break
        }
    }

    /// Verifica se tem permissão de localização
    var hasLocationPermission: Bool {
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        default:
            return false
        }
    }

    // MARK: - Location Updates

    /// Inicia atualizações de localização
    func startUpdatingLocation() {
        guard hasLocationPermission else {
            requestAuthorization()
            return
        }

        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }

    /// Para atualizações de localização
    func stopUpdatingLocation() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }

    /// Obtém localização uma única vez
    func requestLocation() {
        guard hasLocationPermission else {
            requestAuthorization()
            return
        }

        locationManager.requestLocation()
    }

    /// Obtém localização atual (sync - compatibilidade)
    func getCurrentLocation() -> Location? {
        guard let location = currentLocation else { return nil }
        return Location(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }

    /// Obtém localização atual (async)
    func getLocationAsync() async throws -> CLLocation {
        guard hasLocationPermission else {
            throw LocationError.permissionDenied
        }

        // Se já tem localização recente (menos de 30 segundos), retorna
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 30 {
            return location
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            self.locationManager.requestLocation()
        }
    }

    // MARK: - Distance Calculations

    /// Calcula distância entre duas coordenadas
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    /// Calcula distância do usuário até uma coordenada
    func distanceFromUser(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let userLocation = currentLocation else { return nil }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: targetLocation)
    }

    /// Formata distância para exibição
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }

    // MARK: - Geocoding

    /// Obtém endereço a partir de coordenadas
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> String? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return formatPlacemark(placemark)
            }
        } catch {
            print("❌ Erro no geocoding reverso: \(error)")
        }

        return nil
    }

    /// Formata placemark para exibição
    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let street = placemark.thoroughfare {
            components.append(street)
        }
        if let number = placemark.subThoroughfare {
            components.append(number)
        }
        if let neighborhood = placemark.subLocality {
            components.append(neighborhood)
        }

        return components.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentLocation = location
        error = nil

        // Completa continuation se existir
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(returning: location)
        }

        print("📍 Localização atualizada: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Erro de localização: \(error)")

        let locationError: LocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .locationUnknown
            case .network:
                locationError = .networkError
            default:
                locationError = .unknown(error.localizedDescription)
            }
        } else {
            locationError = .unknown(error.localizedDescription)
        }

        self.error = locationError

        // Completa continuation com erro se existir
        if let continuation = locationContinuation {
            locationContinuation = nil
            continuation.resume(throwing: locationError)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        print("📍 Status de autorização mudou: \(authorizationStatus.rawValue)")

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            requestLocation()
        default:
            break
        }
    }
}

// MARK: - Location Error

/// Erros de localização
enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnknown
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permissão de localização negada. Habilite nas Configurações."
        case .locationUnknown:
            return "Não foi possível determinar sua localização."
        case .networkError:
            return "Erro de rede ao obter localização."
        case .unknown(let message):
            return message
        }
    }
}
