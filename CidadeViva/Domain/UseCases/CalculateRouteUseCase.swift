import Foundation

protocol CalculateRouteUseCaseProtocol {
    func execute(from origin: Location, to destination: Location, transportType: Route.TransportType) async throws -> Route
}

final class CalculateRouteUseCase: CalculateRouteUseCaseProtocol {
    private let repository: NavigationRepositoryProtocol

    init(repository: NavigationRepositoryProtocol = NavigationRepository()) {
        self.repository = repository
    }

    func execute(from origin: Location, to destination: Location, transportType: Route.TransportType) async throws -> Route {
        try await repository.calculateRoute(from: origin, to: destination, transportType: transportType)
    }
}
