//
//  CalculateRouteUseCase.swift
//  CidadeViva
//
//  Caso de uso para calcular rotas
//

import Foundation
import CoreLocation

/// Caso de uso para calcular rotas de navegação
final class CalculateRouteUseCase {

    // MARK: - Properties

    private let repository: NavigationRepositoryProtocol

    // MARK: - Initialization

    init(repository: NavigationRepositoryProtocol = NavigationRepository()) {
        self.repository = repository
    }

    // MARK: - Execution

    /// Calcula rota entre dois pontos
    func execute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        mode: RouteMode = .walking
    ) async throws -> Route {
        try await repository.calculateRoute(from: origin, to: destination, mode: mode)
    }
}
