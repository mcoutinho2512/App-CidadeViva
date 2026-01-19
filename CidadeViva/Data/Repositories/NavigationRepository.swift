import Foundation

protocol NavigationRepositoryProtocol {
    func calculateRoute(from origin: Location, to destination: Location, transportType: Route.TransportType) async throws -> Route
}

final class NavigationRepository: NavigationRepositoryProtocol {
    func calculateRoute(from origin: Location, to destination: Location, transportType: Route.TransportType) async throws -> Route {
        // TODO: Implement real route calculation
        return Route(
            id: UUID(),
            origin: origin,
            destination: destination,
            distance: 5000,
            duration: 1200,
            transportType: transportType,
            polyline: nil
        )
    }
}
