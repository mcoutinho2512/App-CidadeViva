import Foundation

@MainActor
final class NavigationViewModel: ObservableObject {
    @Published var route: Route?
    @Published var origin: Location?
    @Published var destination: Location?
    @Published var selectedTransportType: Route.TransportType = .driving
    @Published var isLoading = false
    @Published var error: Error?

    private let calculateRouteUseCase: CalculateRouteUseCaseProtocol

    init(calculateRouteUseCase: CalculateRouteUseCaseProtocol = CalculateRouteUseCase()) {
        self.calculateRouteUseCase = calculateRouteUseCase
    }

    func calculateRoute() async {
        guard let origin = origin, let destination = destination else {
            return
        }

        isLoading = true
        error = nil

        do {
            route = try await calculateRouteUseCase.execute(
                from: origin,
                to: destination,
                transportType: selectedTransportType
            )
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func setCurrentLocationAsOrigin() {
        origin = LocationService.shared.getCurrentLocation()
    }

    func clearRoute() {
        route = nil
        origin = nil
        destination = nil
    }
}
