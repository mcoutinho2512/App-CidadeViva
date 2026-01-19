import Foundation

struct RouteDTO: Codable {
    let id: String
    let originLatitude: Double
    let originLongitude: Double
    let destinationLatitude: Double
    let destinationLongitude: Double
    let distance: Double
    let duration: Double
    let transportType: String

    func toDomain() -> Route {
        Route(
            id: UUID(uuidString: id) ?? UUID(),
            origin: Location(latitude: originLatitude, longitude: originLongitude),
            destination: Location(latitude: destinationLatitude, longitude: destinationLongitude),
            distance: distance,
            duration: duration,
            transportType: Route.TransportType(rawValue: transportType) ?? .driving,
            polyline: nil
        )
    }
}
